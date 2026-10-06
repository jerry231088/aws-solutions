locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Neeraj Singh"
  }

  table_name = "${var.project_name}-${var.environment}-tbl"
  lambda_name = "${var.project_name}-${var.environment}"
}

# ---------------------------------------------------------
# Lambda IAM Policy
# ---------------------------------------------------------

data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan"
    ]

    resources = [
      module.dynamodb.table_arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${local.lambda_name}:*"
    ]
  }
}

# ---------------------------------------------------------
# DynamoDB
# ---------------------------------------------------------

module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name    = local.table_name
  billing_mode  = "PAY_PER_REQUEST"
  hash_key      = "id"
  hash_key_type = "S"

  tags = local.common_tags
}

# ---------------------------------------------------------
# Lambda
# ---------------------------------------------------------

module "lambda" {
  source = "../../modules/lambda"

  function_name = local.lambda_name
  source_file   = "${path.module}/lambda/handler.py"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  env_vars = {
    TABLE_NAME = module.dynamodb.table_name
  }

  policy_json = data.aws_iam_policy_document.lambda.json
}

# ---------------------------------------------------------
# API Gateway
# ---------------------------------------------------------

module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name = "${var.project_name}-${var.environment}"
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn = module.lambda.invoke_arn

  routes = {
    list = "GET /items"

    create = "POST /items"

    get = "GET /items/{id}"

    update = "PUT /items/{id}"

    delete = "DELETE /items/{id}"
  }

  tags = local.common_tags
}