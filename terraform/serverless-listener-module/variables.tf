variable "aws_region" {
  description = "Region where resources are deployed"
  type = string
  default = "us-west-2"
}

data "aws_caller_identity" "current" {
  
}

variable "contract_address" {
  description = "0x address of the contract to send a transaction to through Lambda"
  type = string
}

variable "ecr_repo_name" {
    description = "Name of the ECR repository to store contract listener container in"
    type = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type = string
  default = "transaction-sender"
}

variable "lambda_deployment_package_path" {
  description = "Path to the Lambda deployment package"
}

variable "sqs_queue_name" {
    description = "Name of the SQS queue"
    type = string
}

variable "ecs_cluster_name" {
  type        = string
  description = "Unique key for ecs cluster for application instance."
  default     = "ecs_cluster"
}

variable "ecs_service_name" {
  type        = string
  description = "Name of the ECS service to deploy."
  default     = "ecs_cluster"
}

variable "cpu" {
  description = "Amount of CPU to assign tasks"
  type = number
  default = 256
}

variable "memory" {
  description = "Amount of memory to assign tasks"
  type = number
  default = 1024
}

variable "family_name" {
  description = "Name of the task definition"
  type = string
}

variable "cloudwatch_group_name" {
  description = "Name of the Cloudwatch group to be built for service logging. Must match what's specified in the task definition."
  type = string
}

variable "container_name" {
  description = "Name of container to be run on the service"
  type = string
}

variable "container_port" {
  description = "The port containers use for inbound connections"
  type = number
}

variable "ecs_service_subnets" {
  description = "Subnets to deploy service across"
  type = list(string)
}

variable "ecs_security_groups" {
  description = "SGs to associate with container instances"
  type = list(string)
}

variable "include_efs" {
  description = "Whether or not to include an EFS share in the task definition"
  type = bool
}

variable "efs_share_name" {
  description = "Name of the EFS share to be used by containers if EFS is required"
  type = string
  default = ""
}

variable "efs_share_id" {
  description = "ID of the EFS share to be used by containers if EFS is required"
  type = string
  default = ""
}

variable "efs_host_path" {
  description = "The local path containers will map to the EFS share if EFS is required"
  type = string
  default = ""
}

variable "vpc_cidr" {
  description = "CIDR range of VPC to deploy resources into"
  type = string
}

variable "vpc_id" {
  description = "ID of VPC to deploy resources into"
  type = string
}
