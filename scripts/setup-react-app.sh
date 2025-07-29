#!/bin/bash
set -e

PRE_SIGNED_URL="https://adi-s3-bucket-01.s3.ap-south-1.amazonaws.com/latest-builds/react-app-latest.tar?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAS4MTC57YH7UOBG4W%2F20250729%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20250729T181321Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=b98395dc6db061573b08a0616ea0163b8f2a6fc8f57a994d44a3017721398cd3"
TAR_FILE="/tmp/react-app-latest.tar"
IMAGE_NAME="react-app"

# Install Docker if needed
if ! command -v docker &> /dev/null; then
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
fi

# Download Docker image from S3 (pre-signed URL)
sudo curl -o $TAR_FILE "$PRE_SIGNED_URL"

# Load Docker image
sudo docker load -i $TAR_FILE

# Stop previous container
sudo docker stop react-app || true
sudo docker rm react-app || true

# Run the container
sudo docker run -d --name react-app -p 80:80 react-app:latest
