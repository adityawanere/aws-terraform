#!/bin/bash
set -e

CONTAINER_NAME="react-app"
PORT=80

echo "[INFO] Fetching ECR registry and repo from SSM..."
ECR_REGISTRY=$(aws ssm get-parameter --name "/devops/ecr-registry_url" --with-decryption --query "Parameter.Value" --output text)
ECR_REPO_NAME=$(aws ssm get-parameter --name "/devops/ecr-repo-name" --with-decryption --query "Parameter.Value" --output text)


echo "[INFO] Logging in to ECR..."
aws ecr get-login-password | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "[INFO] Pulling image from ECR..."
docker pull "$ECR_REGISTRY/$ECR_REPO_NAME:latest"

echo "[INFO] Removing old container (if any)..."
docker rm -f "$CONTAINER_NAME" || true

echo "[INFO] Running new container..."
docker run -d -p "$PORT:$PORT" --name "$CONTAINER_NAME" "$ECR_REGISTRY/$ECR_REPO_NAME:latest"

echo "[SUCCESS] Deployment complete!"
