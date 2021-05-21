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

variable "branch" {
  description = "the branch name"
  type        = string
  default     = "master"
}

variable "region" {
  description = "the AWS region"
  type        = string
  default     = "eu-central-1"
}