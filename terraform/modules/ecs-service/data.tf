data "aws_region" "current" {}

# Task role assume policy
data "aws_iam_policy_document" "task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Task logging privileges
data "aws_iam_policy_document" "task_permissions" {
  statement {
    effect = "Allow"

    resources = [
      aws_cloudwatch_log_group.log_group.arn,
      "${aws_cloudwatch_log_group.log_group.arn}:*"
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

# Task permissions to allow ECS Exec command
data "aws_iam_policy_document" "task_ecs_exec_policy" {
  statement {
    effect = "Allow"

    resources = ["*"]

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
  }
}
