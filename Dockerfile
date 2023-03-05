FROM python:3.8.13

RUN apt-get update && apt-get install -y jq \
	&& pip install awscli \
	&& pip install boto3

RUN mkdir /opt/ecs_fargate

WORKDIR /opt/ecs_fargate

COPY ./src/main.py ./

ENTRYPOINT [ "python", "./main.py"]
