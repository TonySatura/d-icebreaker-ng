output "terraform_id" {
  value       = random_id.id.hex
  description = "The unique id of the terraform deployment."
}

output "website_url" {
  value       = "https://${aws_cloudfront_distribution.ui_distribution.domain_name}"
  description = "The public exposed URL of the website application."
}

output "github_connection_hint" {
  value       = "The resource ${aws_codestarconnections_connection.github_connection.name} was initially created in the state PENDING. Authentication with the connection provider must be completed in the AWS Console."
  description = "The public exposed URL of the website application."
}