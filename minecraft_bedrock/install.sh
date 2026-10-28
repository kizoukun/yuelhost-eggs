#!/bin/bash

apt update
apt install -y zip unzip wget curl

if [ ! -d /mnt/server/ ]; then
    mkdir /mnt/server/
fi

cd /mnt/server

# Minecraft CDN Akamai blocks script user-agents
RANDVERSION=$(echo $((1 + $RANDOM % 4000)))

if [ -z "${BEDROCK_VERSION}" ] || [ "${BEDROCK_VERSION}" == "latest" ]; then
    echo -e "\n Downloading latest Bedrock server"
    curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RANDVERSION.212 Safari/537.36" -H "Accept-Language: en" -H "Accept-Encoding: gzip, deflate" -o versions.html.gz https://net-secondary.web.minecraft-services.net/api/v1.0/download/links
    DOWNLOAD_URL=$(zgrep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux/[^"]*' versions.html.gz)
else 
    echo -e "\n Downloading ${BEDROCK_VERSION} Bedrock server"
    DOWNLOAD_URL=https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-$BEDROCK_VERSION.zip
fi

DOWNLOAD_FILE=$(echo ${DOWNLOAD_URL} | cut -d"/" -f5) # Retrieve archive name

# BDS ships allow-list=true with an empty allowlist.json, which rejects every player. Open new servers by default;
# reinstalls keep whatever the owner set.
if [ ! -f server.properties ]; then
    FIRST_INSTALL=1
fi

echo -e "backing up config files"
rm *.bak versions.html.gz
cp server.properties server.properties.bak
cp permissions.json permissions.json.bak
cp allowlist.json allowlist.json.bak


echo -e "Downloading files from: $DOWNLOAD_URL"

curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RANDVERSION.212 Safari/537.36" -H "Accept-Language: en" -o $DOWNLOAD_FILE $DOWNLOAD_URL

echo -e "Unpacking server files"
unzip -o $DOWNLOAD_FILE

echo -e "Cleaning up after installing"
rm $DOWNLOAD_FILE

echo -e "restoring backup config files - on first install there will be file not found errors which you can ignore."
cp -rf server.properties.bak server.properties
cp -rf permissions.json.bak permissions.json
cp -rf allowlist.json.bak allowlist.json

if [ -n "${FIRST_INSTALL}" ]; then
    sed -i 's/^allow-list=.*/allow-list=false/' server.properties
fi

chmod +x bedrock_server

echo -e "Install Completed"
