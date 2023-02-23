# resource "aws_efs_file_system" "app_efs" {
#   creation_token = "production-app-efs"
#   encrypted      = true
#   #kms_key_id     = data.terraform_remote_state.listener-setup.outputs.efs_key_arn
#   tags = {
#     Name = "production-app-efs"
#   }
# }

# resource "aws_efs_mount_target" "efs_mount_target_1a" {
#   file_system_id  = aws_efs_file_system.app_efs.id
#   subnet_id       = module.production_vpc.private_subnets[3]
#   security_groups = [aws_security_group.app_efs_sg.id]
# }

# resource "aws_efs_mount_target" "efs_mount_target_1b" {
#   file_system_id  = aws_efs_file_system.app_efs.id
#   subnet_id       = module.production_vpc.private_subnets[4]
#   security_groups = [aws_security_group.app_efs_sg.id]
# }
