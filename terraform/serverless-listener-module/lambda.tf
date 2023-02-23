# Lambda function
resource "aws_lambda_function" "smart_contract_executor" {
  filename = var.lambda_deployment_package_path
  function_name = var.function_name
  role = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"
  timeout = "180"
  environment {
    variables = {
        "CONTRACT_ADDRESS" = var.contract_address
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_event_mapping" {
  event_source_arn = aws_sqs_queue.contract_event_queue.arn
  function_name = aws_lambda_function.smart_contract_executor.function_name
  batch_size = 1
}
