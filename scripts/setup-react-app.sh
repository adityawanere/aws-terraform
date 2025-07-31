#!/bin/bash
set -e

IMAGE_NAME="__image_name__"
IMAGE_REPO_URL="__image_repo_url__"
IMAGE_TAG="__image_tag__"
AWS_REGION="__aws_region__"

# Install Docker if needed
if ! command -v docker &> /dev/null; then
  echo "[INFO] Installing Docker..."
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
fi

# Install AWS CLI v2 if needed
if ! command -v aws &> /dev/null; then
  echo "[INFO] Installing AWS CLI v2..."
  sudo apt update && sudo apt install -y unzip curl

  # Download and install AWS CLI v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install

  # Cleanup
  rm -rf awscliv2.zip aws
fi

# Authenticate Docker to ECR
echo "[INFO] Authenticating to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | sudo docker login --username AWS --password-stdin "$IMAGE_REPO_URL"

# Pull the latest image from ECR
echo "[INFO] Pulling image $IMAGE_NAME:$IMAGE_TAG..."
sudo docker pull "$IMAGE_REPO_URL/$IMAGE_NAME:$IMAGE_TAG"

# Stop and remove previous container
echo "[INFO] Removing old container (if exists)..."
sudo docker stop react-app || true
sudo docker rm react-app || true

# Run the container
echo "[INFO] Running new container..."
sudo docker run -d --name react-app -p 80:80 "$IMAGE_REPO_URL/$IMAGE_NAME:$IMAGE_TAG"

echo "[SUCCESS] Deployment completed."

# Verify the container is running
if sudo docker ps | grep -q "react-app"; then
  echo "[INFO] React app is running successfully."
else
  echo "[ERROR] React app failed to start."
  exit 1
fi