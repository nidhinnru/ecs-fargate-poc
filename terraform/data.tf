data "aws_region" "current" {}



# Task permissions to allow s3
data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect = "Allow"

    resources = ["*"]

    actions = [
      "s3:*"
    ]
  }
}
