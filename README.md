# AWS Terraform React App Deployment

This project automates the deployment of a React application to AWS
infrastructure using Terraform and GitHub Actions.

## Overview

- **Infrastructure as Code:** Terraform provisions AWS resources (EC2, S3, ECR,
  IAM) and stores remote state in an S3 backend for collaboration and
  reliability.
- **CI/CD Pipeline:** GitHub Actions builds, uploads, and deploys the React app
  to EC2 using AWS SSM.
- **Remote Deployment:** Deployment scripts are executed on EC2 via AWS SSM for
  secure, automated updates.

## Folder Structure

- `.github/workflows/` — CI/CD workflow definitions.
- `app-files/` — Source code for the React application.
- `infra/` — Terraform configuration files for AWS resources.
- `scripts/` — Shell scripts for provisioning and deploying the React app on
  EC2.

## Prerequisites

- AWS account with permissions for EC2, S3, ECR, SSM, and IAM.
- GitHub repository with the following secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`
  - `TF_VAR_key_name`
- SSM parameters set in AWS:
  - `/devops/react-site-ec2-instance-id`
  - `/devops/ecr-registry_url`
  - `/devops/ecr-repo-name`
- EC2 instance with SSM agent installed and IAM permissions.
- S3 bucket for storing React app builds.

## Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/your-org/aws-terraform.git
   cd aws-terraform
   ```

2. **Configure GitHub secrets** as described above.

3. **Push your React app code** to the `react-app/` directory.

4. **Provision AWS resources with Terraform:**

   - Terraform provisioning is automated via GitHub Actions. No manual commands
     are required.
   - When you push changes to the repository, the workflow in
     `.github/workflows/deploy-infra.yml` will:
     - Initialize Terraform in the `infra/` directory.
     - Check formatting and validate the configuration.
     - Create a Terraform plan and apply it automatically to create or update

5. **Build and push the React app using the workflow:**

   - The GitHub Actions workflow will build your React app and upload the latest
     build artifacts to S3.
   - It will build a Docker image, tag it with the version and "latest", and
     push both tags to ECR for versioning and container deployment.
   - The workflow saves the Docker image as a tar file and uploads it to S3
     (`latest-builds/react-app-latest.tar`) for backup and portability.
   - The app version is automatically incremented and committed to
     `version.json` on each

6. **Deploy the latest build to the EC2 instance:**

   - The GitHub Actions workflow will remotely execute deployment scripts via
     AWS SSM to update the EC2 instance with the latest build.
   - It retrieves required parameters (EC2 instance ID, ECR registry URL, ECR
     repo name) from AWS SSM.
   - It generates a pre-signed S3 URL for the latest Docker image tar file and
     injects runtime parameters into the deployment script.
   - The deployment script is sent and executed on the EC2 instance using AWS
     SSM, pulling the latest build and

## Customization

- Modify Terraform files in the `infra/` directory to adjust AWS infrastructure.
- Edit shell scripts in the `scripts/` directory for custom provisioning and
  deployment logic.
- Update workflow YAML files in `.github/workflows/` for

## Troubleshooting

- Check GitHub Actions logs for workflow errors.
- Ensure all AWS resources and SSM parameters exist and are correctly
  configured.
- Verify EC2 instance IAM permissions and SSM agent status.
