resource "aws_iam_role" "lambda_assume_role" {
  name               = "lambda-dynamodb-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "LambdaAssumeRole"
    }
  ]
}
EOF

  tags = local.common_tags
}

resource "aws_iam_role_policy" "dynamodb_read_log_policy" {
  name   = "lambda-dynamodb-log-policy"
  role   = aws_iam_role.lambda_assume_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "logs:*" ],
      "Effect": "Allow",
      "Resource": [ "arn:aws:logs:*:*:*" ]
    },
    {
      "Sid": "ListAndDescribe",
      "Effect": "Allow",
      "Action": [
         "dynamodb:List*",
         "dynamodb:DescribeReservedCapacity*",
         "dynamodb:DescribeLimits",
         "dynamodb:DescribeTimeToLive"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SpecificTable",
      "Effect": "Allow",
      "Action": [
         "dynamodb:BatchGet*",
         "dynamodb:BatchWrite*",
         "dynamodb:CreateTable",
         "dynamodb:DescribeStream",
         "dynamodb:DescribeTable",
         "dynamodb:Delete*",
         "dynamodb:Get*",
         "dynamodb:GetRecords",
         "dynamodb:GetShardIterator",
         "dynamodb:ListShards",
         "dynamodb:ListStreams",
         "dynamodb:PutItem",
         "dynamodb:Query",
         "dynamodb:Scan",
         "dynamodb:Update*"
      ],
      "Resource": [
        "${aws_dynamodb_table.koffee_menu_database.arn}",
        "${aws_dynamodb_table.koffee_menu_database.arn}/*"
      ]
    }
  ]
}
EOF
}
