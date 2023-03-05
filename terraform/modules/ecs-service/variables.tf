# variables.tf

variable "name" {
  description =  "Name of the service"
  default = "poc"
}

variable "cluster_id" {
  description =  "Name of the ECS cluster arn"
  default = ""
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "bradfordhamilton/crystal_blockchain:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "subnet_id" {
  description = "subnet id for ECS service"
}

variable "vpc_id" {
  description = "VPC id for ECS service"
}

variable "assign_public_ip" {
  description = "Enable public ip for the ecs service"
  default = false
}

variable "environment" {
  description = "Environment variables to be passed to the ECS task"
  default = []
}

variable "security_group" {
  description = "ECS Service security group"
}
