# 1. ZIP THE CODE
# This must happen first so Terraform knows the file exists
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/src"
  output_path = "${path.module}/lambda_function_payload.zip"
}

# 2. IAM ROLE & PERMISSIONS
resource "aws_iam_role" "lambda_exec" {
  name = "global_flow_lambda_role_${var.app_region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess" 
}

# 3. LAMBDA FUNCTION
resource "aws_lambda_function" "this" {
  # CHANGED: Now uses the zip file we created above
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  function_name    = "global-api-handler-${var.app_region}"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "python3.12"

  environment {
    variables = {
      TABLE_NAME = "GlobalUserTable"
      REGION     = var.app_region
    }
  }
}

# 4. API GATEWAY
resource "aws_apigatewayv2_api" "this" {
  name          = "global-api-${var.app_region}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.this.invoke_arn
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /status"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

# 5. PERMISSIONS
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}