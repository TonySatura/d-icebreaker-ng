resource "aws_codestarconnections_connection" "github_connection" {
  name          = "github-${random_id.id.hex}"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${local.app_name}-pipeline-artifacts-${random_id.id.hex}"
  acl    = "private"
}

resource "aws_iam_role" "pipeline_role" {
  name = "${local.app_name}-pipeline-${random_id.id.hex}"

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

resource "aws_iam_role_policy" "pipeline_policy" {
  name = "${local.app_name}-pipeline-${random_id.id.hex}"
  role = aws_iam_role.pipeline_role.id

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
    },
    {
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

resource "aws_codepipeline" "codepipeline" {
  name     = "${local.app_name}-pipeline-${random_id.id.hex}"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHubSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId = "${local.github_org}/${local.github_repo}"
        BranchName       = "${local.github_branch}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "AngularBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${local.app_name}-build-${random_id.id.hex}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "S3Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        BucketName = aws_s3_bucket.ui_bucket.id
        Extract    = true
      }
    }
  }
}