#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: ./deploy_airgap.sh release_v1.4.2.tar.gz"
    exit 1
fi

tar -xzf "$1"

cd bundle

echo "Verifying checksums..."

sha256sum -c SHA256SUMS

echo "Loading images..."

docker load -i images/vision_api.tar

docker load -i images/inference_worker.tar

echo "Starting stack..."

docker compose up -d

echo "Deployment completed."