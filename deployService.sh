while getopts k:h:s:f flag
do
    case "${flag}" in
        k) key=${OPTARG};;
        h) hostname=${OPTARG};;
        s) service=${OPTARG};;
        f) force=1;;
    esac
done

if [[ -z "$key" || -z "$hostname" || -z "$service" ]]; then
    printf "\nMissing required parameter.\n"
    printf "  syntax: deployService.sh -k <pem key file> -h <hostname> -s <service> [-f]\n"
    printf "    -f  force: skip the in-progress exam-simulation safety check\n\n"
    exit 1
fi

# Step 0 — Safety preflight: never deploy on top of an in-progress paid 6-hour
# exam simulation (a hard restart / bundle swap would break a paying user
# mid-exam). Runs the check ON THE BOX against the live DB. See
# service/checkActiveExamSims.js. Override with -f only if you accept
# interrupting an active sim.
if [[ "$force" == "1" ]]; then
    printf "\n----> Preflight SKIPPED (-f force)\n"
else
    printf "\n----> Preflight: checking for an in-progress exam simulation\n"
    if ssh -i "$key" ubuntu@$hostname "[ -f services/${service}/.env ]"; then
        scp -q -i "$key" service/checkActiveExamSims.js ubuntu@$hostname:services/${service}/checkActiveExamSims.js
        preflight=$(ssh -i "$key" ubuntu@$hostname "bash -ilc 'cd services/${service} && set -a && . ./.env && set +a && node checkActiveExamSims.js' 2>&1")
        printf "      %s\n" "$preflight"
        if printf "%s" "$preflight" | grep -q PREFLIGHT_BLOCK; then
            printf "\n  Deploy ABORTED — an exam simulation is in progress.\n"
            printf "  Wait for it to finish (target deploy window: 2am Pacific), or re-run with -f to override (interrupts the user).\n\n"
            exit 1
        fi
    else
        printf "      (no prior deployment found — nothing to protect, skipping)\n"
    fi
fi

printf "\n----> Deploying React bundle $service to $hostname with $key\n"

# Step 1
printf "\n----> Build the distribution package\n"
rm -rf build
mkdir build
npm install # make sure vite is installed so that we can bundle
npm run build:seo # build the React front end + prerender public pages (crawlable HTML, sitemap, llms.txt)
cp -rf dist build/public # move the React front end to the target distribution
cp service/*.js build # move the back end service to the target distribution
cp service/package.json service/package-lock.json build
mkdir -p build/middleware build/routes build/db
cp service/middleware/*.js build/middleware
cp service/routes/*.js build/routes
cp service/db/*.js build/db

# Step 2
printf "\n----> Clearing out previous distribution on the target (preserving .env)\n"
ssh -i "$key" ubuntu@$hostname << ENDSSH
if [ -f services/${service}/.env ]; then
  cp services/${service}/.env /tmp/${service}_env_backup
fi
rm -rf services/${service}
mkdir -p services/${service}
if [ -f /tmp/${service}_env_backup ]; then
  mv /tmp/${service}_env_backup services/${service}/.env
fi
ENDSSH

# Step 3
printf "\n----> Copy the distribution package to the target\n"
scp -r -i "$key" build/* ubuntu@$hostname:services/$service

# Step 4
printf "\n----> Deploy the service on the target\n"
ssh -i "$key" ubuntu@$hostname << ENDSSH
bash -i
cd services/${service}
npm install
pm2 reload ${service} --update-env || pm2 restart ${service}
ENDSSH

# Step 5
printf "\n----> Removing local copy of the distribution package\n"
rm -rf build
rm -rf dist
