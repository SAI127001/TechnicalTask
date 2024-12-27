provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "saitechnicaltask" {
  name = "saitechnicaltask"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name   = "lambda_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:*:*"
        },
        {
          Action = [
            "s3:GetObject",
            "rds:*",
            "glue:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_lambda_function" "saitechnicaltask" {
  function_name = "saitechnicaltask"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.saitechnicaltask.repository_url}:latest"
  timeout       = 60
}

output "lambda_function_name" {
  value = aws_lambda_function.saitechnicaltask.function_name
}