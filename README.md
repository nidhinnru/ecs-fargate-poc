# Repo to Setup ECS Fargate Service

## Table of Contents

* [Prerequisites](#prerequisites)
* [S3 Python Script](#s3-python-script)
* [Docker & Docker Compose](#docker-docker-compose)
* [Terraform](#terraform)
* [Notes](#notes)

### Prerequisites

	- Docker CLI to build docker image.
	- Terraform Version >=0.14.3 for executing Terraform scripts. 
	- AWS CLI to be installed for ECR login support.
	- Docker-compose for local testing
	- AWS credentials under user home directory for local testing(aws configure)

### S3 Python Script

A Python script has been created to setup S3 bucket, enable AES256 encryption, disable public access.

#### Script Logic:
	- Allows two input arguments "--s3_bucket_name" & "--region".
        - Check if the bucket already exists, else create a new bucket.
        - Enables AES256 encryption at bucket level.
        - Disable all public access to the bucket.

#### Manual Execution:
```sh
python ./src/main.py --s3_bucket_name=dev-ingest-test --region=us-east-1
```

Alternatively, arguments can also be configured as environment variables, it's expected run the execution as "python [./src/main.py](https://github.com/nidhinnru/ecs-fargate-poc/blob/main/src/main.py)" after setting the environment variables.
```
S3_BUCKET_NAME=dev-ingest-test
AWS_REGION=us-east-1
```

### Docker & Docker Compose

A Dockerfile is placed at the root of the repo which copies python file under "src" folder into container path. Entrypoint has been configured for runtime execution.

Inorder to build the dockerfile and test the docker container locally, a docker-compose file is created with the volume mount, build contexts, environment variables(read from .env file located at root of the repo)

```console
version: "3.9"
services:
  bucket_create:
    image: bucket_create:latest
    build:
      context: ./
      dockerfile: Dockerfile
    environment:
        S3_BUCKET_NAME: ${S3_BUCKET_NAME}
        REGION: ${AWS_REGION}
    volumes:
      - $HOME/aws/credentials:/root/.aws/credentials
```

#### Docker-compose Commands:
```sh
docker-compose build --no-cache ##Build docker image
docker-compose up -d ##Start the container service
docker-compose stop ##Stop the container services
docker-compose down ##To remove all the resources
```

### Terraform

Terraform modules for ECR & ECS services are placed under [terraform/modules](https://github.com/nidhinnru/ecs-fargate-poc/tree/main/terraform/modules) directory

#### Terraform Commands:
```sh
terraform init --upgrade ##Initialize the changes
terraform workspace new dev ##Create new workspace as per env.(e.g dev, beta, & prod)
terraform workspace select dev ##Select the workspace
terraform validate ##Validate the files
terraform plan ##Review the plan
terraform apply ##Apply the plan. 
```

### Notes
	- Terraform deployments for each environments is handled using workspace. 
	- Bash scripts under 'bin' folder is used for ecr authentication and md5 checksum for dockerfile changes.
	- Script expects [environment variables](https://github.com/nidhinnru/ecs-fargate-poc/blob/main/terraform/locals.tf#L20) to be set in ECS task definition.
	- This use case doesn't require load balancer, autoscaling to be configured.
	- ECS task will try to create the bucket, If the bucket already exists it will skip all the steps and task will be stopped. In either case the task will be stopped after the entrypoint execution(this is expected).
