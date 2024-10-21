// S3 Bucket with sensitive Data
resource "aws_s3_bucket" "macie_demo-bucket-sensitive" {
  bucket = "macie-demo-sensitive-${random_id.demo_unique-id.hex}"

  tags = {
    Name      = "Macie Demo Sensitive Data Bucket"
    createdBy = local.owner[0]
    createdAt = local.current_date
    Project   = local.project_name
  }
}


// Encrypt Bucket with S3-SSE
resource "aws_s3_bucket_server_side_encryption_configuration" "macie_demo-bucket_encryption" {
  bucket = aws_s3_bucket.macie_demo-bucket-sensitive.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// Upload sample data to sensitive bucket
resource "aws_s3_object" "provision_sample-data" {
  bucket = aws_s3_bucket.macie_demo-bucket-sensitive.id

  for_each = fileset("test-data/", "**/*.*")

  key          = each.value
  source       = "test-data/${each.value}"
  content_type = each.value
}

// Configure Macie Results Bucket and Configuration
resource "aws_s3_bucket" "macie_demo-results-bucket" {
  bucket        = "macie-demo-results-${random_id.demo_unique-id.hex}"
  force_destroy = true
  tags = {
    Name      = "Macie Demo Results Bucket"
    createdBy = local.owner[0]
    createdAt = local.current_date
    Project   = local.project_name
  }
}

resource "aws_s3_bucket_policy" "allow_Macie_access_to_bucket" {
  bucket = aws_s3_bucket.macie_demo-results-bucket.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "Allow Macie to upload objects to the bucket",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "macie.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.macie_demo-results-bucket.arn}/*"
      },
      {
        "Sid" : "Allow Macie to use the getBucketLocation operation",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "macie.amazonaws.com"
        },
        "Action" : "s3:GetBucketLocation",
        "Resource" : "${aws_s3_bucket.macie_demo-results-bucket.arn}"
      }
    ]
  })

}

// Encrypt Bucket with KMS-SSE
resource "aws_s3_bucket_server_side_encryption_configuration" "macie_demo-results-bucket_encryption" {
  bucket = aws_s3_bucket.macie_demo-results-bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.macie_demo-kms-key.key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

# resource "aws_macie2_classification_export_configuration" "macie_export_config" {
#   depends_on = [
#     aws_macie2_account.macie,
#   ]
#   s3_destination {
#     bucket_name = aws_s3_bucket.macie_demo-results-bucket.bucket
#     key_prefix  = "macie-results/"
#     kms_key_arn = aws_kms_key.macie_demo-kms-key.arn
#   }
# }
