import json
import os

def handler(event, context):
    # This helps us see which region is answering our request
    region = os.environ.get('AWS_REGION', 'unknown')
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from the Global API!',
            'active_region': region,
            'status': 'Healthy'
        })
    }