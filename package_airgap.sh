#!/bin/bash

set -e

VERSION=1.4.2

echo "Creating release bundle..."

mkdir -p bundle/images

docker save devops_challenge-vision_api \
  -o bundle/images/vision_api.tar

docker save devops_challenge-inference_worker \
  -o bundle/images/inference_worker.tar

cp docker-compose.yml bundle/
cp .env.example bundle/
cp -r models bundle/

cd bundle

find . -type f ! -name SHA256SUMS \
  -exec sha256sum {} \; > SHA256SUMS

cd ..

tar -czf release_v${VERSION}.tar.gz bundle

echo "Created release_v${VERSION}.tar.gz"