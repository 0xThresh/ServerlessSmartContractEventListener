# Step 1: Build Docker image locally 
resource "null_resource" "build_docker_image" {
  provisioner "local-exec" {
    command = "docker build -t event-listener-container ../../docker"
  }
}

# Step 2: Build VPC and ECR repo
resource "aws_ecr_repository" "event_listener_ecr" {
  name                 = "event-listener-container"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.2.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.2.1.0/24", "10.2.2.0/24"]
  public_subnets  = ["10.2.101.0/24", "10.2.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
}

# Step 3: Push Docker image to ECR repository using local_exec provisioner
resource "null_resource" "push_to_ecr" {
  triggers = {
    ecr_repository_url = "${aws_ecr_repository.event_listener_ecr.repository_url}"
  }

  provisioner "local-exec" {
    command = "aws ecr get-login-password | docker login --username AWS --password-stdin ${aws_ecr_repository.event_listener_ecr.repository_url} && docker tag event-listener-container:latest ${aws_ecr_repository.event_listener_ecr.repository_url}:latest && docker push ${aws_ecr_repository.event_listener_ecr.repository_url}:latest"
  }
}

# Step 4: Deploy remaining infrastructure
module "serverless-listener" {
  source = "../serverless-listener-module"
  depends_on = [
    null_resource.push_to_ecr
  ]
  
  # Lambda variables
  function_name = "transaction-sender-function"
  contract_address = "0x3f06D24C8F7F6E1eE99Db84A03b3563C89345A05"
  lambda_deployment_package_path = "./transaction-sender.zip"

  # SQS variables
  sqs_queue_name = "contract-event-listener-queue"

  # ECR variables
  ecr_repo_name = aws_ecr_repository.event_listener_ecr.repository_url

  # ECS variables
  ecs_cluster_name = "production-ecs-cluster"
  ecs_service_name = "event-listener"

  container_name              = "event-listener"
  container_port              = 80
  ecs_service_subnets = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]
  vpc_cidr = module.vpc.vpc_cidr_block
  vpc_id   = module.vpc.vpc_id

  ecs_security_groups   = [aws_security_group.event-listener-sg.id]
  cloudwatch_group_name = "/ecs/event-listener"
  cpu                   = 256
  include_efs           = false
  family_name           = "event-listener"
  memory                = 512
}

resource "aws_security_group" "event-listener-sg" {
  name        = "event-listener-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
