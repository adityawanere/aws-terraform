## Overview

- **Infrastructure as Code:** Terraform provisions AWS resources (EC2, S3, ECR,
  IAM) and manages remote state in an S3 backend for reliability and
  collaboration.
- **CI/CD Pipeline:** GitHub Actions builds the React app, creates a Docker
  image, pushes it to ECR, and triggers deployment to EC2 using AWS SSM.
- **Remote Deployment:** Deployment scripts are executed on EC2 via AWS SSM,
  which pulls the latest Docker image directly from ECR for secure, automated
  updates.

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

## Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/your-org/aws-terraform.git
   cd aws-terraform
   ```

2. **Configure GitHub secrets** as described above.

3. **Push your React app code** to the `app-files/` directory.

4. **Provision AWS resources with Terraform:**

   - Terraform provisioning is automated via GitHub Actions. No manual commands
     are required.
   - When you push changes to the repository, the workflow in
     `.github/workflows/deploy-infra.yml` will:
     - Initialize Terraform in the `infra/` directory.
     - Check formatting and validate the configuration.
     - Create a Terraform plan and apply it automatically to create or update
       AWS resources.

5. **Build and push the React app using the workflow:**

   - The GitHub Actions workflow will build your React app, create a Docker
     image, and push it to ECR for versioning and deployment.
   - The app version is automatically incremented and committed to
     `version.json` on each build.

6. **Deploy the latest build to the EC2 instance:**

   - The GitHub Actions workflow will remotely execute deployment scripts via
     AWS SSM to update the EC2 instance.
   - The deployment script pulls the latest Docker image from ECR and restarts
     the app container.

## Customization

- Modify Terraform files in the `infra/` directory to adjust AWS infrastructure.
- Edit shell scripts in the `scripts/` directory for custom provisioning and
  deployment logic.
- Update workflow YAML files in `.github/workflows/` for CI/CD changes.

## Troubleshooting

- Check GitHub Actions logs for workflow errors.
- Ensure all AWS resources and SSM parameters exist and are correctly
  configured.
- Verify EC2 instance IAM permissions and SSM agent status.
- In case latest image is not deployed properly, check the run-command logs in
  SSM.
