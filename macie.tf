// Enable AWS Macie Service
resource "aws_macie2_account" "macie" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}



// Create Macie Custom Data Identifier
resource "aws_macie2_custom_data_identifier" "macie_custom_data_identifier" {
  name                   = "Gotham Passport"
  regex                  = "[ABCDEF]\\d{7}[A-Z]"
  description            = "Passport number of Gotham Citizens"
  maximum_match_distance = 50
  keywords               = ["passport"]
  ignore_words           = ["ignore"]

  depends_on = [aws_macie2_account.macie]
}

// Create scheduled Macie Analysis Job
resource "aws_macie2_classification_job" "demo-job" {
  job_type = "SCHEDULED"
  name     = "S3-Demo-Job-${random_id.demo_unique-id.hex}_${local.current_timestamp}"
  schedule_frequency {
    daily_schedule = true
  }
  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.macie_demo-bucket-sensitive.id]
    }
  }
  depends_on = [aws_macie2_account.macie]
  tags = {
    createdBy = var.owner
    createdAt = local.current_date
    Project   = local.project_name

  }
}

// Generate sample findings via CLI command
resource "null_resource" "macie_sample_content" {
  provisioner "local-exec" {
    command = "aws macie2 create-sample-findings --profile bIT-Playground-PowerUser"
  }
}
