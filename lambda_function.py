import json
import os
import boto3

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    message = json.dumps(event)
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    sns_client.publish(
        TopicArn=sns_topic_arn,
        Message=message,
        Subject='Macie Finding Alert'
    )
    return {
        'statusCode': 200,
        'body': json.dumps('Message sent to SNS topic')
    }