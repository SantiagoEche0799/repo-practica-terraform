terraform {
    backend "s3" {
        bucket         = "devops-directive-remote-tf-state"
        key            = "organization-and-modules/terraform-aws-infra/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "terraform-state-locking"
        encrypt        = true
    }

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.region
}
