resource "aws_iam_role_policy" "task_policy" {
  name   = "s3-policy"
  role   = module.ecs_service.ecs_task_role
  policy = data.aws_iam_policy_document.s3_policy.json
}
