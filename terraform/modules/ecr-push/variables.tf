variable "dockerfile_dir" {
  type = string
  description = "The directory that contains the Dockerfile"
}


variable "docker_image_tag" {
  type        = string
  description = "This is the tag which will be used for the image that you created"
  default     = "latest"
}

variable "name" {
  type        = string
  description = "Repository name."
}

variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Defaults to IMMUTABLE"
  default     = "IMMUTABLE"
}

variable "scan_image_on_push" {
  type        = bool
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)"
  default     = true
}

variable "lifecycle_policy" {
  type        = string
  description = "ECR Lifecycle Policy (json string) to manage the image lifecycles in the ECR repository. Defaults to keep only the last 100 images."
  default     = <<L_POLICY
{
  "rules": [
    {
      "action": {
        "type": "expire"
      },
      "selection": {
        "countType": "imageCountMoreThan",
        "countNumber": 100,
        "tagStatus": "any"
      },
      "description": "Only keep 100 images",
      "rulePriority": 10
    }
  ]
}
L_POLICY
}

variable "repository_policy" {
  type        = string
  description = "ECR Repository Policy (json string) to manage access to the ECR repository. Defaults to allow CodeBuild service to pull any image from this ECR repo."
  default     = <<R_POLICY
{
  "Version": "2008-10-17",
  "Statement": [
	{
	  "Sid": "pull",
	  "Effect": "Allow",
	  "Principal": {
		"Service": "codebuild.amazonaws.com"
	  },
	  "Action": [
		"ecr:GetDownloadUrlForLayer",
		"ecr:BatchGetImage",
		"ecr:BatchCheckLayerAvailability"
	  ]
	}
  ]
}
R_POLICY
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to Fargate service and task definition and other resources. Defaults to {}"
  default     = {}
}
