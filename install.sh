#!/usr/bin/env bash
set -exo pipefail

IFS="" read -r -p "Enter license key: " -s key
if [[ ! "$key" =~ ^[0-9a-zA-Z]{64}$ ]]; then
    >&2 echo "Invalid license key."
    exit 1
fi

dockerComposeFile="docker-compose.yml"
dockerComposeFileSha256="52a131107cb93e20491566277514d8bce017b807ca0ba27ebfeef54a68fbf1eb"
if [[ -f "$dockerComposeFile" ]]; then
    >&2 echo "$dockerComposeFile already exists."
    exit 2
fi

username="user-${key:0:32}"
password="${key:32:32}"

sudo apt-get update
sudo apt-get -y install docker.io docker-compose
echo "$password" | docker login -u "$username" --password-stdin registry.everytrade.io
curl "https://raw.githubusercontent.com/rpanak-generalbytes/everytrade-install/c1eb8965a9ecb5fb206f8f8e6911bfc0d89de5fd/docker-compose.yml" -o "$dockerComposeFile"
sha256sum "$dockerComposeFile" | grep "$dockerComposeFileSha256"
sudo docker-compose pull
sudo docker-compose up -d