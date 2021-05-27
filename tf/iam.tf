# === UI ===

data "aws_iam_policy_document" "iam_ui_policy" {
  statement {
    actions   = ["s3:GetBucket*", "s3:GetObject*", "s3:List*"]
    resources = [aws_s3_bucket.ui_bucket.arn, "${aws_s3_bucket.ui_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.ui_oai.iam_arn]
    }
  }
}


# === Pipeline ===

resource "aws_iam_role" "iam_pipeline_role" {
  name                  = "${local.app_name}-pipeline-${random_id.id.hex}"
  force_detach_policies = true
  tags                  = local.base_tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_pipeline_policy" {
  name = "${local.app_name}-pipeline-${random_id.id.hex}"
  role = aws_iam_role.iam_pipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.pipeline_bucket.arn}",
        "${aws_s3_bucket.pipeline_bucket.arn}/*"
      ]
    },{
      "Action": [
        "s3:DeleteObject*",
        "s3:PutObject*",
        "s3:Abort*"
      ],
      "Resource": [
        "${aws_s3_bucket.ui_bucket.arn}",
        "${aws_s3_bucket.ui_bucket.arn}/*"
      ],
      "Effect": "Allow"
    },{
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${aws_codestarconnections_connection.github_connection.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


# === CodeBuild ===

resource "aws_iam_role" "iam_build_role" {
  name                  = "${local.app_name}-pipeline-build-${random_id.id.hex}"
  force_detach_policies = true
  tags                  = local.base_tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_build_policy" {
  name = "${local.app_name}-build-${random_id.id.hex}"
  role = aws_iam_role.iam_build_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },{
      "Action": [
        "s3:GetObject*",
        "s3:GetBucket*",
        "s3:List*",
        "s3:DeleteObject*",
        "s3:PutObject*",
        "s3:Abort*"
      ],
      "Resource": [
        "${aws_s3_bucket.pipeline_bucket.arn}",
        "${aws_s3_bucket.pipeline_bucket.arn}/*"
      ],
      "Effect": "Allow"
    }
  ]
}
POLICY
}