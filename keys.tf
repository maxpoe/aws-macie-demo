// Generate KMS Key
resource "aws_kms_key" "macie_demo-kms-key" {
  description = "Macie Demo KMS Key"
  tags = {
    Name      = "Macie Demo KMS Key"
    createdBy = var.owner
    createdAt = local.current_date
    Project   = local.project_name
  }
}

resource "aws_kms_alias" "macie_demo-kms-key-alias" {
  name          = "alias/macie-demo-key"
  target_key_id = aws_kms_key.macie_demo-kms-key.key_id
}

resource "aws_kms_key_policy" "macie_demo-kms-policy" {
  key_id = aws_kms_key.macie_demo-kms-key.key_id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = local.user_arn
        },
        Action   = "kms:*"
        Resource = "${aws_kms_key.macie_demo-kms-key.arn}"
      },
      {
        "Sid" : "Allow Macie to use the key",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "macie.amazonaws.com"
        },
        "Action" : [
          "kms:GenerateDataKey",
          "kms:Encrypt"
        ],
        "Resource" : "${aws_kms_key.macie_demo-kms-key.arn}",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : "118227868267"
          },
          "ArnLike" : {
            "aws:SourceArn" : [
              "arn:aws:macie2:eu-central-1:118227868267:export-configuration:*",
              "arn:aws:macie2:eu-central-1:118227868267:classification-job/*"
            ]
          }
        }
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = local.user_arn
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })
}
