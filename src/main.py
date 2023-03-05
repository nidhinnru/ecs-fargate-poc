import os
import sys
import boto3
import botocore
import optparse
import logging
from botocore.exceptions import ClientError
from logging import handlers
from logging.handlers import RotatingFileHandler

def args_parse():
    """
    Argument parser function to receive all input variables
    """
    parser = optparse.OptionParser()
    parser.add_option("-b", "--s3_bucket_name", action="store", dest="s3_bucket_name", help="query string", default=os.environ.get('S3_BUCKET_NAME'))
    parser.add_option("-r", "--region", action="store", dest="region", help="query string", default=os.environ.get('AWS_REGION'))
    options, args = parser.parse_args()
    return options

def init_logger():
    """
    Initializing logger function for log parsing
    """
    global logger
    logger = logging.getLogger('-')
    logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    wr_formatter = logging.Formatter("%(asctime)s-%(levelname)s-%(message)s<br/>")
    fh = handlers.RotatingFileHandler('offboard_user.log', maxBytes=(1048576*5), backupCount=7)
    fh.setFormatter(wr_formatter)
    logger.addHandler(fh)
    return logger

def check_bucket(bucket_name, region=None):
    """
    Check if s3 bucket exists
    """
    try:
        s3 = boto3.resource('s3', region_name=region)
        bucket = s3.Bucket(bucket_name)
        s3.meta.client.head_bucket(Bucket=bucket_name)
        logger.warning("A bucket with name {} already exists, try creating the bucket with a different name.".format(bucket_name))
        logger.debug("Exiting...")
        sys.exit()
        return True
    except botocore.exceptions.ClientError as e:
        logger.info("Proceeding to create s3 bucket {} in {}".format(bucket_name, region))
        # If a client error is thrown, then check that it was a 404 error.
        # If it was a 404 error, then the bucket does not exist.
        error_code = int(e.response['Error']['Code'])
        if error_code == 403:
            logger.error("Private bucket, Forbidden Access with status code: {}".format(error_code))
            return True
        elif error_code == 404:
            logger.debug("S3 bucket does not exist, proceeding to create s3 bucket.")
            create_bucket(bucket_name, region)
            return False


def create_bucket(bucket_name, region=None):
    """
    Create an S3 bucket in a specified region
    :param bucket_name: Bucket to create
    :param region: String region to create bucket in, e.g., 'us-west-2'
    :return: True if bucket created, else False
    """

    # Create bucket
    try:
            s3_client = boto3.client('s3', region_name=region)
            create_response = s3_client.create_bucket(
                    Bucket=bucket_name,
                    ACL='private'
                    )
            logger.info("Bucket created successfully, response: {}".format(create_response))
            public_block_response = s3_client.put_public_access_block(
                Bucket=bucket_name,
                PublicAccessBlockConfiguration={
                    'BlockPublicAcls': True,
                    'IgnorePublicAcls': True,
                    'BlockPublicPolicy': True,
                    'RestrictPublicBuckets': True
                    },
            )
            logger.info("Blocked all public access to the S3 bucket.")
            encryption_response = s3_client.put_bucket_encryption(
                Bucket=bucket_name,
                ServerSideEncryptionConfiguration={
                "Rules": [
                    {"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}
                ]
                },
            )
            logger.info("Enabled AES256 encryption for the bucket")

    except ClientError as e:
        logger.error("An error occured during s3 bucket creation. Error Response: {}".format(e))
        return False
    return True


if __name__ == '__main__':
    init_logger()
    options=args_parse()
    check_bucket(options.s3_bucket_name, options.region)

sys.exit()
