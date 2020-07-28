#!/usr/bin/env bash
set -exo pipefail

IFS="" read -r -p "Enter license key: " -s key
if [[ ! "$key" =~ ^[0-9a-zA-Z]{64}$ ]]; then
    >&2 echo "Invalid license key."
    exit 1
fi

dockerComposeFile="docker-compose.yml"
dockerComposeFileSha256="3a9c560dbd60c3431a3f7b5b39c7d04a667eb0338ee56956d060e684e4ae5a12"
if [[ -f "$dockerComposeFile" ]]; then
    >&2 echo "$dockerComposeFile already exists."
    exit 2
fi

username="user-${key:0:32}"
password="${key:32:32}"

sudo apt-get update
sudo apt-get -y install docker.io docker-compose
echo "$password" | docker login -u "$username" --password-stdin registry.everytrade.io
curl "https://raw.githubusercontent.com/rpanak-generalbytes/everytrade-install/e20d7874411090400207d8dacca8da407939ad16/docker-compose.yml" -o "$dockerComposeFile"
sha256sum "$dockerComposeFile" | grep "$dockerComposeFileSha256"
sudo docker-compose pull
sudo docker-compose up -d