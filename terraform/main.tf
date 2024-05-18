terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }
}

provider "aws" {
  # Configuration options

  default_tags {
    tags = {
      "Name"      = "${var.service_name}-service"
      "ManagedBy" = "Terraform"
      "Service"   = var.service_name
    }
  }
}

variable "domain" {
  type        = string
  description = "The email domain name."
}

variable "service_name" {
  type        = string
  description = "The name of the service. This will be the prefix for all services created under this project."
}