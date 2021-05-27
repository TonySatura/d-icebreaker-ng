output "terraform_id" {
  value       = random_id.id.hex
  description = "The unique id of the terraform deployment."
}

output "website_url" {
  value       = "https://${aws_cloudfront_distribution.ui_distribution.domain_name}"
  description = "The public exposed URL of the website application."
}