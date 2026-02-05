# Opportunities Tracker

A cloud-native opportunity tracking application built with Go, MongoDB, and Kubernetes. Track sales opportunities, manage pipelines, and monitor deal values with a modern, responsive web interface.

## Overview

This is a full-stack application featuring:
- RESTful API built with Go and Gin framework
- MongoDB database for persistent storage
- JWT-based authentication and authorization
- Kubernetes deployment on AWS EKS
- Infrastructure as Code with Terraform
- Automated CI/CD pipeline with security scanning

## Architecture

```
GitHub → CodePipeline → CodeBuild → ECR → EKS
                ↓
         Security Scanning
         (Checkov, Trivy, Inspector)
                ↓
         Security Hub / GuardDuty
```

**Components:**
- **Application**: Go-based opportunity tracker with MongoDB
- **Infrastructure**: AWS (VPC, EKS, EC2, S3, ECR)
- **CI/CD**: GitHub Actions + AWS CodePipeline/CodeBuild
- **Security**: Inspector, Security Hub, Config, CloudTrail, GuardDuty

## Features

- **User Management**: Secure signup and login with JWT authentication
- **Opportunity Tracking**: Create, read, update, and delete sales opportunities
- **Deal Values**: Track monetary values for each opportunity
- **Status Management**: Monitor opportunity status (open/closed)
- **User Isolation**: Each user sees only their own opportunities
- **Responsive UI**: Clean, modern interface that works on all devices
- **RESTful API**: Well-documented API endpoints for integration

## Prerequisites

- AWS Account with admin access
- GitHub account
- AWS CLI configured
- kubectl installed
- Terraform >= 1.0
- Docker installed
- Go 1.21+ (for local development)

## Quick Start

### 1. Clone Repository

```bash
git clone <your-repo-url>
cd wiz
```

### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply

# Save outputs
terraform output -json > ../outputs.json
```

### 3. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name wiz-exercise-eks
kubectl get nodes
```

### 4. Build and Deploy Application

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build and push
docker build -t wiz-app .
docker tag wiz-app:latest <ecr-url>:latest
docker push <ecr-url>:latest

# Deploy to Kubernetes
kubectl apply -f k8s/

# Get application URL
kubectl get ingress -n wiz-app
```

## CI/CD Pipeline Setup

### GitHub Actions (Security Scanning)

1. Fork this repository
2. Enable GitHub Actions
3. Security scans run automatically on push/PR

### AWS CodePipeline (Infrastructure & App Deployment)

1. Create CodePipeline with two stages:
   - **Stage 1**: Infrastructure deployment (buildspec-infra.yml)
   - **Stage 2**: Application build & deploy (buildspec-app.yml)

2. Connect to GitHub repository

3. Configure environment variables:
   - `AWS_ACCOUNT_ID`
   - `AWS_DEFAULT_REGION`
   - `IMAGE_REPO_NAME`
   - `EKS_CLUSTER_NAME`

## Security Controls

### Preventative Controls

- Branch protection rules
- Required PR reviews
- Automated security scanning in CI/CD
- IaC scanning (Checkov, tfsec)
- Container scanning (Trivy)
- Secret scanning (Gitleaks)
- Dependency scanning (Dependabot, govulncheck)

### Detective Controls

- AWS CloudTrail (audit logging)
- AWS Config (compliance monitoring)
- AWS Security Hub (centralized findings)
- Amazon Inspector (code & infrastructure scanning)
- AWS GuardDuty (threat detection)

## Project Structure

```
wiz/
├── auth/                   # JWT authentication
├── controllers/            # API controllers
├── database/              # MongoDB connection
├── models/                # Data models
├── assets/                # Frontend (HTML/CSS/JS)
├── terraform/             # Infrastructure as Code
│   ├── main.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── ec2-mongodb.tf
│   ├── s3.tf
│   └── ...
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── ...
├── .github/workflows/     # GitHub Actions
├── buildspec-infra.yml    # Infrastructure pipeline
├── buildspec-app.yml      # Application pipeline
├── Dockerfile
├── SECURITY.md            # Security documentation
├── DEMO.md               # Demonstration guide
└── README.md
```

## Demonstration

See [DEMO.md](DEMO.md) for complete demonstration guide including:
- Environment setup
- Vulnerability demonstration
- Security detection
- CI/CD pipeline
- Remediation steps

## Application Features

- User signup/login with JWT authentication
- Track opportunities with name and value
- CRUD operations for opportunities
- User-specific opportunity lists
- Clean, modern UI with Wiz branding

## API Endpoints

### Authentication
- `POST /signup` - Create new user
- `POST /login` - Login user
- `GET /opportunities` - Opportunities page (requires auth)

### Opportunities
- `GET /opportunities/:userid` - Get all opportunities for user
- `GET /opportunity/:id` - Get single opportunity
- `POST /opportunity/:userid` - Create new opportunity
- `PUT /opportunity` - Update opportunity
- `DELETE /opportunity/:userid/:id` - Delete opportunity
- `DELETE /opportunities/:userid` - Delete all opportunities

## Cleanup

```bash
# Delete Kubernetes resources
kubectl delete namespace wiz-app

# Destroy infrastructure
cd terraform
terraform destroy -auto-approve
```

## Cost Estimate

Running this environment costs approximately **$5-10/day**:
- EKS cluster: ~$0.10/hour ($2.40/day)
- EC2 instances: ~$0.05/hour ($1.20/day)
- NAT Gateway: ~$0.045/hour ($1.08/day)
- ALB: ~$0.025/hour ($0.60/day)
- Other services: ~$0.50/day

## Security Tools Used

- **Checkov**: IaC security scanning
- **tfsec**: Terraform security scanner
- **Trivy**: Container vulnerability scanner
- **Gitleaks**: Secret detection
- **gosec**: Go security checker
- **govulncheck**: Go vulnerability scanner
- **AWS Inspector**: Code and infrastructure scanning
- **AWS Security Hub**: Centralized security findings
- **AWS GuardDuty**: Threat detection
- **AWS Config**: Compliance monitoring
- **AWS CloudTrail**: Audit logging

## Tech Stack

- **Language**: Go 1.21
- **Framework**: Gin
- **Database**: MongoDB 4.4 (intentionally outdated)
- **Container**: Docker
- **Orchestration**: Kubernetes (EKS)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions + AWS CodePipeline/CodeBuild
- **Cloud**: AWS

## License

This project is for educational purposes only. See [LICENSE](LICENSE) for details.

## Contact

For questions about this exercise: [Your Email]

## Acknowledgments

- Original todo app: https://github.com/dogukanozdemir/golang-todo-mongodb
- Wiz Security for the exercise requirements
