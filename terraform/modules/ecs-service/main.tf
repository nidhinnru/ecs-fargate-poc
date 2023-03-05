# ecs.tf

data "template_file" "container_def" {
  template = file("${path.module}/templates/app.json.tpl")

  vars = {
    name           = var.name
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = data.aws_region.current.name
    log_group_name = aws_cloudwatch_log_group.log_group.name 
    environment    = jsonencode(var.environment)
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.container_def.rendered
}

resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.security_group]
    subnets          = var.subnet_id
    assign_public_ip = var.assign_public_ip
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

