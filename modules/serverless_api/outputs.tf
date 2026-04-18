output "base_url" {
  description = "URL for the API Gateway stage"
  value       = "${aws_apigatewayv2_stage.this.invoke_url}/status"
}

output "api_endpoint" {
  description = "The specific endpoint to trigger the Lambda"
  # This combines the generated API URL with our /status route
  value = "${aws_apigatewayv2_stage.this.invoke_url}/status"
}

