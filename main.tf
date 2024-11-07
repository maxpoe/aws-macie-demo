// AWS Macie Demo using Terraform IaC
// Copyright (c) 24.09.2024 by Maximilian Pöhls, bridgingIT. 
// www.bridgingIT.de
// -----------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

// Get current User Session to label resources accordingly
data "aws_caller_identity" "current" {}

locals {
  user_arn          = data.aws_caller_identity.current.arn
  current_timestamp = timestamp()
  current_date      = formatdate("YYYY-MM-DD", timestamp())
  project_name      = "AWS Macie Demo"
}

// Uniuqe ID for this session, e.g. s3 bucket name, lambda function, ...
resource "random_id" "demo_unique-id" {
  byte_length = 8
}







