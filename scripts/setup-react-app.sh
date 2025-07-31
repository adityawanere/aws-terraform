#!/bin/bash
set -e

IMAGE_NAME="__image_name__"
IMAGE_REPO_URL="__image_repo_url__"
IMAGE_TAG="__image_tag__"
AWS_REGION="__aws_region__"

# Install Docker if needed
if ! command -v docker &> /dev/null; then
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
fi

# Install AWS CLI if needed
if ! command -v aws &> /dev/null; then
  sudo apt update && sudo apt install -y unzip
  sudo curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
  sudo unzip awscli-bundle.zip

  # Create Symlink for Python3 
  sudo ln -s /usr/bin/python3 /usr/bin/python
  # Install Python3.12 venv
  sudo apt install python3.12-venv

  #install AWS CLI
  sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws << y
fi

# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $IMAGE_REPO_URL

# Pull the latest image from ECR
sudo docker pull $IMAGE_REPO_URL/$IMAGE_NAME:$IMAGE_TAG

# Stop previous container
sudo docker stop react-app || true
sudo docker rm react-app || true

# Run the container
sudo docker run -d --name react-app -p 80:80 $IMAGE_REPO_URL/$IMAGE_NAME:$IMAGE_TAG

