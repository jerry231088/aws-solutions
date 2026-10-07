data "archive_file" "function" {
  type        = "zip"
  source_file = var.source_file
  output_path = "${path.module}/.build/${var.function_name}.zip"
}

resource "aws_iam_role" "function_exec_role" {
  name = "${var.function_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "function_role_policy" {
  name   = "${var.function_name}-execution-policy"
  policy = var.policy_json
  role   = aws_iam_role.function_exec_role.id
}

resource "aws_lambda_function" "function" {
  function_name    = var.function_name
  filename         = data.archive_file.function.output_path
  source_code_hash = data.archive_file.function.output_base64sha256
  handler          = var.handler
  runtime          = var.runtime
  role             = aws_iam_role.function_exec_role.arn
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = var.env_vars
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name = "/aws/lambda/${aws_lambda_function.function.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}
