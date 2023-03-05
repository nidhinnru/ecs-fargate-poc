
## ECR Repo create module ##
module "ecr" {
  source = "./modules/ecr-push"
  name   = format("%s-poc-app", local.env)
  dockerfile_dir = "../"
}

## ECR Cluster create resource ##
resource "aws_ecs_cluster" "main" {
  name = format("%s-poc-cluster", local.env)
}

## ECS Service create module ##
module "ecs_service" {
  source = "./modules/ecs-service"
  name             = local.name
  cluster_id       = aws_ecs_cluster.main.id
  app_image        = module.ecr.repository_url
  app_count        = 1
  fargate_cpu      = 256
  fargate_memory   = 512
  app_port         = local.app_port
  subnet_id        = local.private_subnet_id
  vpc_id           = local.vpc_id
  assign_public_ip = false
  environment      = local.s3_bucket_environment
  security_group   = aws_security_group.ecs_tasks.id
}
