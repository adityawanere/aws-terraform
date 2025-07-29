#!/bin/bash
set -e

PRE_SIGNED_URL="__signed_url__"
TAR_FILE="/tmp/react-app-latest.tar"
IMAGE_NAME="__image_name__"
IMAGE_REPO_URL="__image_repo_url__"

# Install Docker if needed
if ! command -v docker &> /dev/null; then
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
fi

# Delete older File if it exists
if [ -f "$TAR_FILE" ]; then
  sudo rm -f "$TAR_FILE"
fi

# Download Docker image from S3 (pre-signed URL)
sudo curl -o $TAR_FILE "$PRE_SIGNED_URL"

# Load Docker image
sudo docker load -i $TAR_FILE

# Stop previous container
sudo docker stop react-app || true
sudo docker rm react-app || true

# Run the container
sudo docker run -d --name react-app -p 80:80 $IMAGE_REPO_URL/$IMAGE_NAME:latest
