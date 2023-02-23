resource "aws_ecs_service" "ecs_service" {
  depends_on = [
    aws_iam_role.ecs_task_definition_role
  ]
  name = var.ecs_service_name
  cluster = aws_ecs_cluster.ecs-cluster.arn
  task_definition = var.include_efs ? aws_ecs_task_definition.ecs_task_definition_with_efs[0].arn : aws_ecs_task_definition.ecs_task_definition_without_efs[0].arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets = var.ecs_service_subnets
    assign_public_ip = false
    security_groups = var.ecs_security_groups
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition_with_efs" {
  count = var.include_efs ? 1 : 0
  family = var.family_name
  task_role_arn = aws_iam_role.ecs_task_role.arn

  cpu = var.cpu
  memory = var.memory
  execution_role_arn = aws_iam_role.ecs_task_definition_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      "name": "${var.container_name}",
      "image": "${var.ecr_repo_name}",
      "command": [
        
      ],
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group" : "${var.cloudwatch_group_name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ])

  volume {
    name = var.efs_share_name

    efs_volume_configuration {
      file_system_id = var.efs_share_id
      transit_encryption = "ENABLED"
      root_directory = var.efs_host_path
    }
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition_without_efs" {
  count = var.include_efs ? 0 : 1
  family = var.family_name
  task_role_arn = aws_iam_role.ecs_task_role.arn

  cpu = var.cpu
  memory = var.memory
  execution_role_arn = aws_iam_role.ecs_task_definition_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]

    container_definitions = jsonencode([
    {
      "name": "${var.container_name}",
      "image": "${var.ecr_repo_name}",
      "command": [
        
      ],
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group" : "${var.cloudwatch_group_name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ])
}


# Below resources can be edited for autoscaling
/*
resource "aws_appautoscaling_target" "ecs_autoscale_target" {
  max_capacity = 2
  min_capacity = 1
  resource_id = "service/${var.cluster_name}/${aws_ecs_service.event_listener_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}
resource "aws_appautoscaling_policy" "ecs_autoscale_policy" {
  name = "${var.resource_prefix}-ecs-autoscaling-policy"
  resource_id = aws_appautoscaling_target.ecs_autoscale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_autoscale_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_autoscale_target.service_namespace
  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment = 1
    }
  }
}*/