variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_image_uri" {
  type = string
}

variable "name_value" {
  type = string
}

locals {
  name = "${var.project}-${var.environment}-api"
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = merge(local.tags, { Name = "${local.name}-role" })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 30
  tags              = merge(local.tags, { Name = "${local.name}-logs" })
}

resource "aws_lambda_function" "api" {
  function_name = local.name
  package_type  = "Image"
  image_uri     = var.lambda_image_uri
  role          = aws_iam_role.lambda.arn
  timeout       = 10
  memory_size   = 256
  publish       = true

  environment {
    variables = {
      NAME = var.name_value
    }
  }

  tags = merge(local.tags, { Name = local.name })
}

resource "aws_lambda_alias" "current" {
  name             = var.environment
  function_name    = aws_lambda_function.api.function_name
  function_version = aws_lambda_function.api.version
}

resource "aws_apigatewayv2_api" "http" {
  name          = "${local.name}-httpapi"
  protocol_type = "HTTP"
  tags          = merge(local.tags, { Name = "${local.name}-httpapi" })
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_alias.current.arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = var.environment
  auto_deploy = true
  tags        = merge(local.tags, { Name = "${local.name}-stage" })
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
