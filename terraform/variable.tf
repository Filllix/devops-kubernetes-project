variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "devops-kubernetes-project"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}