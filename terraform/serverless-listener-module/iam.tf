# IAM resources required for ECS and Lambda
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    sid = "ECSAssumeRolePolicy"
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ecs_container_policy" {
  statement {
    sid = "WriteToECS"
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]
    resources = ["*"]
  }

  statement {
    sid = "PullImageFromECR"
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"]
    resources = ["*"] 
  }

  statement {
    sid = "WriteLogsToCloudWatch"
    effect = "Allow"
    actions = ["logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"]
    resources = [
      #aws_cloudwatch_log_group.ecs-cluster-log-group.arn,
      "*"
    ]
  }

  statement {
    sid = "WriteMessagesToSQS"
    effect = "Allow"
    actions = ["sqs:SendMessage"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_container_policy" {
  name = "ecsContainerPolicy"
  description = "Allows ECS containers/ tasks to connect to EFS shares"
  policy = data.aws_iam_policy_document.ecs_container_policy.json
}

resource "aws_iam_role" "ecs_task_definition_role" {
  name = "ecsTaskDefinitionRole"
  description = "Take definition role for ECS services"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "efs_policy_role_attach" {
  policy_arn = aws_iam_policy.ecs_container_policy.arn
  role = aws_iam_role.ecs_task_definition_role.name
}

# Container task IAM resources
data "aws_iam_policy_document" "ecs_fargate_switchrole_policy" {
  statement {
    sid = "ECSAssumeRolePolicy"
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ECSTaskRole"
  description = "Role used for allowing ECS containers to communicate with ECS service APIs"
  assume_role_policy = data.aws_iam_policy_document.ecs_fargate_switchrole_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_efs_policy_role_attach" {
  policy_arn = aws_iam_policy.ecs_container_policy.arn
  role = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"
  description = "Policy to allow Lambda to write to CloudWatch Logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = "*"
        #Resource = "${aws_sqs_queue.contract_event_queue.arn}"
      },
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name = "lambda_attachment"
  roles = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}
