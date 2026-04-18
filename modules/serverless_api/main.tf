# modules/serverless_api/main.tf

# 1. The HTTP API Gateway
resource "aws_apigatewayv2_api" "this" {
  name          = "global-api-${var.app_region}"
  protocol_type = "HTTP"
}

# 2. The API Stage (Managed CloudWatch logging and auto-deploy)
resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

# 3. The Lambda Integration (Connecting the API to your Python code)
resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.this.invoke_arn
}

# 4. The Route (Any GET request triggers the integration)
resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /status"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

# 5. Permission for API Gateway to call Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

# modules/serverless_api/main.tf (continued)

resource "aws_lambda_function" "this" {
  filename      = "lambda_function_payload.zip" # We'll automate this zip later
  function_name = "global-api-handler-${var.app_region}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "python3.12"

  environment {
    variables = {
      TABLE_NAME = "GlobalUserTable"
      REGION     = var.app_region
    }
  }
}