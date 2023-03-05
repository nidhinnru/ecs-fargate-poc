# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = format("%s-task-exec-role", var.name)
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#####
# IAM - Task role, basic. Append policies to this role for S3, DynamoDB etc.
#####
resource "aws_iam_role" "task" {
  name               = format("%s-task-role", var.name)
  assume_role_policy = data.aws_iam_policy_document.task_assume.json

}

resource "aws_iam_role_policy" "log_agent" {
  name   = format("%s-log-permissions", var.name)
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_permissions.json
}

resource "aws_iam_role_policy" "ecs_exec_inline_policy" {
  name   = format("%s-ecs-exec-permissions", var.name)
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_ecs_exec_policy.json
}
