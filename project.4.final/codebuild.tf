## AWS CODEBUILD PROJECT {{{1
resource "aws_codebuild_project" "app_build" {
  name           = "${local.prefix}-app-build"
  badge_enabled  = false
  build_timeout  = 60
  queued_timeout = 480
  service_role   = aws_iam_role.app_codebuild_role.arn

  artifacts {
    encryption_disabled = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    git_clone_depth = 1
    type            = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id = aws_vpc.main.id

    subnets = [
      aws_subnet.AppA.id,
      aws_subnet.AppB.id,
      aws_subnet.AppC.id
    ]

    security_group_ids = [ aws_security_group.AppSG.id ]
  }

  tags = local.common_tags
}
