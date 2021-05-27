resource "aws_codestarconnections_connection" "github_connection" {
  # The aws_codestarconnections_connection resource is created in the state PENDING. 
  # Authentication with the connection provider must be completed in the AWS Console.
  name          = "${local.github_org}-github-connection"
  provider_type = "GitHub"
  tags          = local.base_tags
}

resource "aws_s3_bucket" "pipeline_bucket" {
  bucket        = "${local.app_name}-pipeline-artifacts-${random_id.id.hex}"
  acl           = "private"
  force_destroy = true
  tags          = local.base_tags
}

resource "aws_s3_bucket_public_access_block" "pipeline_bucket_public_access" {
  bucket                  = aws_s3_bucket.pipeline_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_codepipeline" "pipeline" {
  name     = "${local.app_name}-pipeline-${random_id.id.hex}"
  role_arn = aws_iam_role.iam_pipeline_role.arn
  tags     = local.base_tags

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
        ConnectionArn        = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId     = "${local.github_org}/${local.github_repo}"
        BranchName           = "${local.github_branch}"
        OutputArtifactFormat = "CODE_ZIP"
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
        ProjectName = aws_codebuild_project.build.name
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

resource "aws_codebuild_project" "build" {
  name         = "${local.app_name}-build-${random_id.id.hex}"
  service_role = aws_iam_role.iam_build_role.arn
  tags         = local.base_tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type = "CODEPIPELINE"
  }
}