terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = ">= 4.0"
    docker = {
      source  = "kreuzwerker/docker"
      version = ">2.12"
    }
  }
  backend "local" {}
}