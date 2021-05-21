terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.41"
    }
  }
}

locals {
  app_name    = "d-icebreaker${var.branch != "master" ? "-${var.branch}" : ""}"
  branch      = var.branch
  environment = var.environment
  github_user = "TonySatura"
  github_repo = "d-icebreaker-ng"
  profile     = var.profile
  region      = var.region
  tags_common = {
    branch      = var.branch
    environment = var.environment
    name        = local.app_name
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