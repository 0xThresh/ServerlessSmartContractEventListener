resource "aws_cloudwatch_log_group" "ecs-cluster-log-group" {
  name = var.cloudwatch_group_name
}

resource "aws_cloudwatch_log_group" "lambda-cluster-log-group" {
  name = "/aws/lambda/transaction-sender-function"
}