variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "wiz-exercise"
}

variable "mongodb_version" {
  description = "Outdated MongoDB version"
  type        = string
  default     = "4.4"
}

variable "ubuntu_version" {
  description = "Outdated Ubuntu AMI"
  type        = string
  default     = "20.04"
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "mongodb_backup_schedule" {
  description = "Cron expression for MongoDB backups"
  type        = string
  default     = "cron(0 2 * * ? *)" # Daily at 2 AM UTC
}
