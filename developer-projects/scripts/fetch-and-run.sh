#!/bin/bash
set -euo pipefail

NEXUS_URL="http://localhost:8081"
REPO="npm-hosted"
NEXUS_USER="deploy-user"
WORK_DIR="/tmp/node-deploy"

if [ -z "${NEXUS_PASS:-}" ]; then
    echo "ERROR: NEXUS_PASS is not set"
    exit 1
fi

SEARCH_URL="$NEXUS_URL/service/rest/v1/search/assets?repository=$REPO&sort=version&direction=desc"

DOWNLOAD_URL=$(curl -s -u "$NEXUS_USER:$NEXUS_PASS" "$SEARCH_URL" | jq -r '.items[0].downloadUrl')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo "ERROR: No artifact found in $REPO"
    exit 1
fi

echo "Newest artifact: $DOWNLOAD_URL"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
curl -s -f -u "$NEXUS_USER:$NEXUS_PASS" -o app.tgz "$DOWNLOAD_URL"

tar -xzf app.tgz
cd package
npm install --omit=dev

VERSION=$(jq -r '.version' package.json)
echo "Running bootcamp-node-project $VERSION"
node server.js
