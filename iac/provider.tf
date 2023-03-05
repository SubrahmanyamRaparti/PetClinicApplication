terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
  }
}

data "aws_region" "current" {} # Get the AWS region

data "aws_caller_identity" "current" {} # Get AWS account ID

data "aws_availability_zones" "available" {} # Get AWS Availabality Zones