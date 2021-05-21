terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.41"
    }
  }
}

locals {
  app_name    = "d-icebreaker${var.environment != "master" ? "-${var.branch}" : ""}"
  branch      = var.branch
  environment = var.environment
  github_user = "TonySatura"
  github_repo = "d-icebreaker-ng"
  profile     = var.profile
  region      = var.region
  tags        = {
    app-name    = local.app_name
    branch      = var.branch
    environment = var.environment
    owner       = "t.satura@icloud.com"
    github      = "${local.github_user}/${local.github_repo}"
  }
}

provider "aws" {
  profile = "tonomony"
  region  = local.region
}

resource "random_id" "id" {
  byte_length = 8
}