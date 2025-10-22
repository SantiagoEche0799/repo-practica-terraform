terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-0bbdd8c17ed981ef9" # Ubuntu 20.04 LTS // us-east-1
  instance_type = "t3.micro"
}
