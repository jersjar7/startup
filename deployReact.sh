#!/bin/bash

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
    printf "  syntax: deployReact.sh -k <pem key file> -h <hostname> -s <service> [-f]\n"
    printf "    -f  force: skip the in-progress exam-simulation safety check\n\n"
    exit 1
fi

# Safety preflight: a frontend deploy wipes services/<svc>/public and re-copies;
# a user mid 6-hour exam simulation who refreshes (or hits a now-deleted lazy
# chunk) would break. Skip the deploy if a sim is in progress. See
# service/checkActiveExamSims.js. Override with -f.
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

printf "\n----> Build the distribution package\n"
rm -rf build
mkdir build
npm install # make sure vite is installed so that we can bundle
npm run build:seo # build the React front end + prerender public pages (crawlable HTML, sitemap, llms.txt)
cp -rf dist/* build # move the React front end to the target distribution

printf "\n----> Clearing out previous distribution on the target\n"
ssh -i "$key" ubuntu@$hostname << ENDSSH
rm -rf services/${service}/public
mkdir -p services/${service}/public
ENDSSH

printf "\n----> Copy the distribution package to the target\n"
scp -r -i "$key" build/* ubuntu@$hostname:services/$service/public

printf "\n----> Removing local copy of the distribution package\n"
rm -rf build
rm -rf dist