resource "aws_ecr_repository" "repository" {
  name                 = var.app_ecr_repository_name
  image_tag_mutability = "MUTABLE"

  tags = local.common_tags
}

resource "aws_ecr_repository_policy" "repository-policy" {
  repository = aws_ecr_repository.repository.name
  policy     = data.aws_iam_policy_document.admin.json
}

data "aws_iam_policy_document" "push_and_pull" {
  statement {
    sid    = "ECR Push And Pull"
    effect = "Allow"

    principals {
      identifiers = [local.current_account]
      type        = "AWS"
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
  }
}

data "aws_iam_policy_document" "admin" {
  source_json = data.aws_iam_policy_document.push_and_pull.json

  statement {
    sid    = "ECR Admin"
    effect = "Allow"

    principals {
      identifiers = [local.current_account]
      type        = "AWS"
    }

    actions = [
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]
  }
}
