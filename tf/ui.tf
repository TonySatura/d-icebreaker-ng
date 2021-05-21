resource "aws_s3_bucket" "ui_bucket" {
  bucket = "${local.app_name}-ui-${random_id.id.hex}"
  acl    = "private"
  website {
    index_document = "index.html"
  }
  tags = local.tags
}

resource "aws_cloudfront_origin_access_identity" "ui_oai" {
  comment = "OAI for ${local.app_name} UI"
}

data "aws_iam_policy_document" "iam_policy" {
  statement {
    actions   = ["s3:GetBucket*", "s3:GetObject*", "s3:List*"]
    resources = [aws_s3_bucket.ui_bucket.arn, "${aws_s3_bucket.ui_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.ui_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.ui_bucket.id
  policy = data.aws_iam_policy_document.iam_policy.json
}

# resource "aws_route53_record" "ui_record" {
#   count   = var.use_custom_domain ? 1 : 0
#   zone_id = data.aws_route53_zone.hosted_zone[0].zone_id
#   name    = var.subdomain
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.placeholder_image_generator_cloudfront.domain_name
#     zone_id                = aws_cloudfront_distribution.placeholder_image_generator_cloudfront.hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# data "aws_acm_certificate" "ui_certificate" {
#   count    = var.use_custom_domain ? 1 : 0
#   provider = aws.us_east
#   domain   = var.certificate_domain
# }

# data "aws_route53_zone" "hosted_zone" {
#   count = var.use_custom_domain ? 1 : 0
#   name  = var.domain
# }

resource "aws_cloudfront_distribution" "ui_distribution" {
  comment             = "Cloudfront distribution for ${local.app_name} UI"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.ui_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.ui_bucket.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.ui_oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.ui_bucket.bucket

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 1
    default_ttl            = 1 * 60 * 60 * 24
    max_ttl                = 1 * 60 * 60 * 24 * 365
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.tags

}