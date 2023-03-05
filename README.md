# Repo to Setup ECS Fargate Service

## Table of Contents

* [Prerequisites](#prerequisites)
* [S3 Python Script](#s3-python-script)
* [Docker & Docker Compose](#docker-docker-compose)
* [Terraform](#terraform)


### Prerequisites

	- Docker CLI to build docker image.
	- Terraform Version >=0.14.3 for executing Terraform scripts. 
	- AWS CLI to be installed for ECR login support.
	- Docker-compose for local testing
	- AWS credentials under user home directory for local testing(aws configure)

### S3 Python Script

Python script has been created to create S3 bucket, enable AES256 encryption, disable public access.

Script Logic:
        - Check if the bucket already exists, else create a new bucket.
        - Enables AES256 encryption at bucket level
        - Disable all public access to the bucket

It allows two input arguments "--s3_bucket_name" & "--region".

Manual Execution:
```sh
python ./src/main.py --s3_bucket_name=dev-ingest-test --region=us-east-1
```

Alternatively, arguments can also be configured as environment variables, it's expected run the execution as "python [./src/main.py](https://github.com/nidhinnru/ecs-fargate-poc/blob/main/src/main.py)" after setting the environment variables.
```
S3_BUCKET_NAME=dev-ingest-test
AWS_REGION=us-east-1
```

### Docker & Docker Compose

A Dockerfile is placed at the root of the repo which copies python file under "src" folder into container path. Entrypoint has been configured for runtime execution. contains [the minimum requirement](https://docs.docker.com/engine/installation/binaries/#check-kernel-dependencies) for Docker.

Inorder to build the dockerfile and test the docker container, a docker-compose file is created with the volume mount, build contexts, environment variables(read from .env file)

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

Docker-compose Commands:
```sh
docker-compose build --no-cache ##Build docker image
docker-compose up -d ##Start the container service
docker-compose stop ##Stop the container services
docker-compose down ##To remove all the resources
```

### Terraform

Terraform modules are placed under [terraform/modules]() directory

If you're not willing to run a random shell script, please see the [installation](https://docs.docker.com/engine/installation/linux/) instructions for your distribution.

If you are a complete Docker newbie, you should follow the [series of tutorials](https://docs.docker.com/engine/getstarted/) now.

Get the server version:

```console
$ docker version --format '{{.Server.Version}}'
1.8.0
```

You can also dump raw JSON data:

```console
$ docker version --format '{{json .}}'
{"Client":{"Version":"1.8.0","ApiVersion":"1.20","GitCommit":"f5bae0a","GoVersion":"go1.4.2","Os":"linux","Arch":"am"}
```
