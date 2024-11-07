// Creation of Workflow to work with the results of macie

// Create SNS Topic
resource "aws_sns_topic" "macie_findings_topic" {
  name = "macie-findings-topic-${random_id.demo_unique-id.hex}"
  tags = {
    createdBy = var.owner
    createdAt = local.current_date
    Project   = local.project_name

  }
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.macie_findings_topic.arn
  protocol  = "email"
  endpoint  = var.email
}

// Create Lambda Function
resource "aws_iam_role" "lambda_role-macie" {
  name = "macie_findings_lambda_role-${random_id.demo_unique-id.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "macie_findings_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sns:Publish"
          ]
          Resource = aws_sns_topic.macie_findings_topic.arn
        }
      ]
    })
  }
  tags = {
    createdBy = var.owner
    createdAt = local.current_date
    Project   = local.project_name

  }
}

resource "aws_lambda_function" "macie_findings_function" {
  filename         = "lambda_function.zip"
  function_name    = "macie_findings_handler-${random_id.demo_unique-id.hex}"
  role             = aws_iam_role.lambda_role-macie.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda_function.zip")

  tags = {
    createdBy = var.owner
    createdAt = local.current_date
    Project   = local.project_name

  }

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.macie_findings_topic.arn
    }
  }
}


// Create EventBridge Rule & Target
resource "aws_cloudwatch_event_rule" "macie-findings_rule" {
  name        = "Macie-Findings-${random_id.demo_unique-id.hex}"
  description = "Get Macie Findings for further processing"

  event_pattern = jsonencode({
    "source" : ["aws.macie"]
  })

  tags = {
    createdBy = var.owner
    createdAt = local.current_date
    Project   = local.project_name

  }
}

resource "aws_cloudwatch_event_target" "macie-findings-target" {
  target_id = "Macie-Findings-Processor"
  rule      = aws_cloudwatch_event_rule.macie-findings_rule.name
  arn       = aws_lambda_function.macie_findings_function.arn
}


resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.macie_findings_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.macie-findings_rule.arn
}

