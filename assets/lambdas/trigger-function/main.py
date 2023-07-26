import os
import boto3
import json
import concurrent.futures

from aws_lambda_powertools import Logger

logger = Logger()
lbd = boto3.client("lambda")

LAMBDA_ARN = os.environ["LAMBDA_ARN"]
NB_EXECUTION = int(os.environ["NB_EXECUTION"])

@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    # Invoke in parallel the Lambda function passed as parameter NB_EXECUTION times
    with concurrent.futures.ThreadPoolExecutor(max_workers=NB_EXECUTION) as executor:
        futures = [executor.submit(invoke_lambda) for _ in range(NB_EXECUTION)]
    for response in concurrent.futures.as_completed(futures):
        logger.info(response.result())

def invoke_lambda():
    lbd_response = lbd.invoke(
        FunctionName=LAMBDA_ARN,
        InvocationType="RequestResponse",
        Payload="{}"
    )
    lbd_json_response = json.loads(lbd_response["Payload"].read())
    return lbd_json_response.get("body")
