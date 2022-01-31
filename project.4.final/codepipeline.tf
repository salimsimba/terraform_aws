resource "aws_codepipeline" "app_pipeline" {
  name     = "app-pipeline"
  role_arn = aws_iam_role.app_codepipeline_role.arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      input_artifacts  = []
      output_artifacts = [ "source_output" ]
      run_order        = 1
      version          = "1"

      configuration = {
        "BranchName"     = var.app_repository_branch
        "RepositoryName" = aws_codecommit_repository.code_repo.repository_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [ "source_output" ]
      output_artifacts = [ "build_output"  ]
      run_order        = 1
      version          = "1"

      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "AWS_DEFAULT_REGION"
              type  = "PLAINTEXT"
              value = var.aws_region
            },
            {
              name  = "AWS_ACCOUNT_ID"
              type  = "PLAINTEXT"
              value = local.account_id
            },
            {
              name  = "CONTAINER_NAME"
              type  = "PLAINTEXT"
              value = var.app_container_name
            },
            {
              name  = "IMAGE_NAME"
              type  = "PLAINTEXT"
              value = var.app_image_name
            },
            {
              name  = "REPOSITORY_URI"
              type  = "PLAINTEXT"
              value = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_image_name}"
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.app_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      input_artifacts  = [ "build_output" ]
      output_artifacts = []
      run_order        = 1
      version          = "1"

      configuration = {
        "ClusterName" = aws_ecs_cluster.ecs_cluster.name
        "ServiceName" = aws_ecs_service.app_service.name
        "FileName"    = "imagedefinitions.json"
      }
    }
  }

  depends_on = [
    aws_codebuild_project.app_build,
    aws_ecs_cluster.ecs_cluster,
    aws_ecs_service.app_service,
    aws_ecr_repository.repository,
    aws_codecommit_repository.code_repo,
    aws_s3_bucket.cicd_bucket,
  ]

  tags = local.common_tags
}
