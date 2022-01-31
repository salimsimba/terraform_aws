resource "aws_s3_bucket" "destination_bucket" {
  provider = aws.west
  bucket   = var.dstBucketName

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "source_bucket" {
  bucket   = var.srcBucketName
  acl      = "private"

  versioning {
    enabled = true
  }

  replication_configuration {
    role = aws_iam_role.replication_role.arn

    rules {
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.destination_bucket.arn
        storage_class = "STANDARD"
      }
    }
  }
}
