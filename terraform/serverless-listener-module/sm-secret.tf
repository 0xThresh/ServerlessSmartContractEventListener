resource "aws_secretsmanager_secret" "private_key" {
  description = "Secret to manually add private key to. DO NOT USE A KEY FROM A WALLET WITH SIGNIFICANT AMOUNT OF ASSETS!!!!!"
  name = "ETH_PRIVATE_KEY"
  force_overwrite_replica_secret = true
}