#!/bin/bash
# Set secrets in the production .env without them appearing in shell history or
# in a remote process list.
#
#   ./scripts/set-prod-secrets.sh -k secrets/jerson-cs260-key.pem -h fe4raccoons.com -s startup
#
# Interactive by default: prompts with terminal echo off. If stdin is not a TTY
# it reads KEY=VALUE lines instead, one per line, so it can be driven by a pipe.
#
# Secrets travel to the box on STDIN, never as ssh arguments (which would be
# visible in `ps` to anyone on the host). The helper that applies them is
# shipped separately, because stdin can only carry one of the two.
#
# A timestamped backup of the remote .env is kept for rollback.
set -euo pipefail

while getopts k:h:s: flag; do
  case "${flag}" in
    k) key=${OPTARG};;
    h) hostname=${OPTARG};;
    s) service=${OPTARG};;
    *) ;;
  esac
done

if [[ -z "${key:-}" || -z "${hostname:-}" || -z "${service:-}" ]]; then
  printf "\nMissing required parameter.\n"
  printf "  syntax: set-prod-secrets.sh -k <pem key file> -h <hostname> -s <service>\n\n"
  exit 1
fi

STRIPE_SECRET_KEY=""
STRIPE_WEBHOOK_SECRET=""

if [ -t 0 ]; then
  printf "\nSetting secrets on %s (service: %s).\n" "$hostname" "$service"
  printf "Input is hidden. Press Enter to leave a value unchanged.\n\n"
  read -rsp "STRIPE_SECRET_KEY   (sk_live_…): " STRIPE_SECRET_KEY; printf "\n"
  read -rsp "STRIPE_WEBHOOK_SECRET (whsec_…): " STRIPE_WEBHOOK_SECRET; printf "\n"
else
  while IFS= read -r line; do
    case "$line" in
      STRIPE_SECRET_KEY=*) STRIPE_SECRET_KEY="${line#*=}";;
      STRIPE_WEBHOOK_SECRET=*) STRIPE_WEBHOOK_SECRET="${line#*=}";;
    esac
  done
fi

# Sanity-check the prefixes before touching production. Catching a pasted TEST
# key here is the whole point: prod silently ran on sk_test for ~12 days and
# collected no money on a real student's purchase.
if [[ -n "$STRIPE_SECRET_KEY" && "$STRIPE_SECRET_KEY" != sk_live_* ]]; then
  printf "\n  REFUSING: STRIPE_SECRET_KEY does not start with sk_live_.\n\n"
  exit 1
fi
if [[ -n "$STRIPE_WEBHOOK_SECRET" && "$STRIPE_WEBHOOK_SECRET" != whsec_* ]]; then
  printf "\n  REFUSING: STRIPE_WEBHOOK_SECRET does not start with whsec_.\n\n"
  exit 1
fi
if [[ -z "$STRIPE_SECRET_KEY" && -z "$STRIPE_WEBHOOK_SECRET" ]]; then
  printf "\n  Nothing to do.\n\n"
  exit 0
fi

# The applier reads KEY=VALUE lines from stdin, so no secret is ever an argument.
HELPER_LOCAL=$(mktemp)
HELPER_REMOTE="/tmp/fe4-set-env-$$.sh"
trap 'rm -f "$HELPER_LOCAL"' EXIT

cat > "$HELPER_LOCAL" <<'REMOTE'
set -euo pipefail
ENV_FILE="services/${SERVICE}/.env"
[ -f "$ENV_FILE" ] || { echo "  no $ENV_FILE on the box"; exit 1; }
cp "$ENV_FILE" "${ENV_FILE}.bak.$(date +%s)"

while IFS= read -r line; do
  [ -z "$line" ] && continue
  k="${line%%=*}"
  v="${line#*=}"
  if grep -q "^${k}=" "$ENV_FILE"; then
    # Substitute via a file so the value is never re-parsed by a shell or by
    # sed's replacement syntax.
    printf '%s\n' "$v" > /tmp/.fe4val
    awk -v key="$k" 'BEGIN{getline val < "/tmp/.fe4val"}
      index($0, key "=")==1 {print key "=" val; next} {print}' \
      "$ENV_FILE" > "${ENV_FILE}.tmp"
    mv "${ENV_FILE}.tmp" "$ENV_FILE"
    rm -f /tmp/.fe4val
    echo "  updated ${k}"
  else
    printf '%s=%s\n' "$k" "$v" >> "$ENV_FILE"
    echo "  appended ${k}"
  fi
done

chmod 600 "$ENV_FILE"
echo "  --- keys present ---"
grep -oE '^[A-Z_]+=' "$ENV_FILE" | tr -d '=' | sort | sed 's/^/      /'
echo "  STRIPE mode: $(grep -oE '^STRIPE_SECRET_KEY=sk_(live|test)' "$ENV_FILE" || echo unknown)"
REMOTE

scp -q -i "$key" "$HELPER_LOCAL" "ubuntu@${hostname}:${HELPER_REMOTE}"

printf "\n----> Applying to %s\n" "services/${service}/.env"
{
  [ -n "$STRIPE_SECRET_KEY" ] && printf 'STRIPE_SECRET_KEY=%s\n' "$STRIPE_SECRET_KEY"
  [ -n "$STRIPE_WEBHOOK_SECRET" ] && printf 'STRIPE_WEBHOOK_SECRET=%s\n' "$STRIPE_WEBHOOK_SECRET"
} | ssh -i "$key" "ubuntu@${hostname}" \
      "SERVICE='${service}' bash ${HELPER_REMOTE}; rm -f ${HELPER_REMOTE} /tmp/.fe4val"

printf "\n----> Reloading pm2 so the new env is picked up\n"
ssh -i "$key" "ubuntu@${hostname}" "bash -ilc 'pm2 reload ${service} --update-env || pm2 restart ${service}'"

printf "\nDone. Verify with a real checkout: the session id must start with cs_live_.\n\n"
