resource "aws_dynamodb_table" "koffee_menu_database" {
  name             = "koffee-menu-database"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "Beverage"
  range_key        = "Size"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "Beverage"
    type = "S"
  }

  attribute {
    name = "Size"
    type = "S"
  }

  provisioner "local-exec" {
    command = "python ./resources/populate_db.py ${var.dynamodbDbName} ${var.loadFileName} ${var.destRegion} ${var.dstBucketName} ${var.backupFileName}"
  }

  depends_on = [
    aws_s3_bucket.source_bucket,
    aws_s3_bucket.destination_bucket,
  ]

  tags = local.common_tags
}
