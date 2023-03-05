
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.57.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

# Checks if build folder has changed
data "external" "build_dir" {
  program = ["bash", "${path.root}/../bin/dir_md5.sh", var.dockerfile_dir]
}

# Builds test-service and pushes it into aws_ecr_repository
resource "null_resource" "ecr_image" {
  triggers = {
    build_folder_content_md5 = data.external.build_dir.result.md5
  }

  # Runs the build.sh script which builds the dockerfile and pushes to ecr
  provisioner "local-exec" {
    command = "bash ${path.root}/../bin/build.sh ${var.dockerfile_dir} ${aws_ecr_repository.repo.repository_url}:${var.docker_image_tag} ${data.aws_caller_identity.current.account_id} ${data.aws_region.current.name}"
  }
}

resource "aws_ecr_repository" "repo" {
  name = var.name

  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_image_on_push
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  policy     = var.lifecycle_policy
  repository = aws_ecr_repository.repo.name
}
resource "aws_ecr_repository_policy" "repo_policy" {
  policy     = var.repository_policy
  repository = aws_ecr_repository.repo.name
}
