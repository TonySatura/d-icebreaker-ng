variable "profile" {
  description = "the AWS user profile"
  type        = string
  default     = "tonomony"
}

variable "environment" {
  description = "the environment (prod, dev, staging)"
  type        = string
  default     = "prod"
}

variable "github_branch" {
  description = "the branch name"
  type        = string
  default     = "main"
}

variable "region" {
  description = "the AWS region"
  type        = string
  default     = "eu-central-1"
}