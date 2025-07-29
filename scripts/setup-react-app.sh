#!/bin/bash
set -e

PRE_SIGNED_URL="$1"
TAR_FILE="/tmp/react-app-latest.tar"
IMAGE_NAME="react-app"

# Install Docker if needed
if ! command -v docker &> /dev/null; then
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
fi

# Download Docker image from S3 (pre-signed URL)
curl -o $TAR_FILE "$PRE_SIGNED_URL"

# Load Docker image
docker load -i $TAR_FILE

# Stop previous container
docker stop react-app || true
docker rm react-app || true

# Run the container
docker run -d --name react-app -p 80:80 $IMAGE_NAME:latest
