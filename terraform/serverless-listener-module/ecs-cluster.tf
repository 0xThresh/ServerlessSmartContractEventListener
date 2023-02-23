resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.ecs_cluster_name

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs-cluster-log-group.name
      }
    }
  }
}
