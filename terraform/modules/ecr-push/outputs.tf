output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
}

output "lifecycle_policy" {
  value = aws_ecr_lifecycle_policy.lifecycle_policy
}

output "repository_policy" {
  value = aws_ecr_repository_policy.repo_policy
}
