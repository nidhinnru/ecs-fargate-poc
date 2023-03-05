locals {
  env  = terraform.workspace
  name = format("%s-s3-bucket-create", local.env)
  private_subnet_id = lookup(local.private_subnet_ids, local.env)
  vpc_id = lookup(local.vpc_ids, local.env)
  region = data.aws_region.current.name 
  app_port = "3000"

  private_subnet_ids = {
    dev  = ["subnet-5677888853", "subnet-014456788"]
    beta = [""]
    prod = [""]
  }
  vpc_ids =  {
    dev  = "vpc-0e73e596a0d995109"
    beta = ""
    prod = ""
  }

  s3_bucket_environment = [{"name": "S3_BUCKET_NAME", "value": "dev-ingest-test-4"},
                 {"name": "AWS_REGION", "value": local.region}]
}
