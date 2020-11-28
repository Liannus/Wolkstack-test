resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "deploy_apps"
  acl    = "private"
}

resource "aws_codepipeline" "deploy_apps" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.deploy_apps.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      run_order        = 1
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["source_artifacts"]

      configuration = {
        "Owner"                = var.repository_owner
        "Repo"                 = var.repository_name
        "Branch"               = var.repository_branch
        "PollForSourceChanges" = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_artifacts"]
      run_order       = 2
      version         = "1"

      configuration = {
        "ProjectName" = "deploy_apps",
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            }
          ]
        )
      }
    }
  }
}

# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
# Would probably be better to pull this from the environment
# or something like SSM Parameter Store.
resource "random_string" "github_secret" {
  length  = 99
  special = false
}

resource "aws_codepipeline_webhook" "deploy_apps" {
  name            = "webhook-github-deploy_apps"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.deploy_apps.name

  authentication_configuration {
    secret_token = random_string.github_secret.result
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

  tags = {}
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "deploy_apps" {
  repository = var.repository_name
  events     = ["push"]

  configuration {
    url          = aws_codepipeline_webhook.deploy_apps.url
    content_type = "json"
    insecure_ssl = "0"
    secret       = random_string.github_secret.result
  }
}
