terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.41"
    }
  }
}

locals {
  app_name      = "d-icebreaker${var.environment != "prod" ? "-${var.environment}" : ""}${var.github_branch != "main" ? "-${var.github_branch}" : ""}"
  environment   = var.environment
  github_org    = "TonySatura"
  github_repo   = "d-icebreaker-ng"
  github_branch = var.github_branch
  profile       = var.profile
  region        = var.region
  tags = {
    app-name    = local.app_name
    branch      = var.github_branch
    environment = var.environment
    owner       = "t.satura@icloud.com"
    github      = "${local.github_org}/${local.github_repo}"
  }
}

provider "aws" {
  profile = "tonomony"
  region  = local.region
}

resource "random_id" "id" {
  byte_length = 8
}