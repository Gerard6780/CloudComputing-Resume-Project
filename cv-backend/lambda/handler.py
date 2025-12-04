"""
AWS Lambda Handler for CV Portfolio API
Handles GET requests to retrieve CV data from DynamoDB and increment view counter
"""

import json
import os
import boto3
from botocore.exceptions import ClientError

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')

# Get table name from environment variable
TABLE_NAME = os.environ.get('TABLE_NAME', 'curriculums')
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    """
    Main Lambda handler function
    
    Args:
        event: API Gateway event object
        context: Lambda context object
        
    Returns:
        dict: API Gateway response with status code, headers, and body
    """
    
    # Log the incoming event for debugging
    print(f"Received event: {json.dumps(event)}")
    
    # Extract query parameters
    query_params = event.get('queryStringParameters') or {}
    cv_id = query_params.get('id')
    
    # Validate required parameter
    if not cv_id:
        return create_response(400, {
            'error': 'Missing required parameter: id',
            'message': 'Please provide an id query parameter'
        })
    
    try:
        # Get item from DynamoDB
        response = table.get_item(Key={'id': cv_id})
        
        # Check if item exists
        if 'Item' not in response:
            return create_response(404, {
                'error': 'CV not found',
                'message': f'No CV found with id: {cv_id}'
            })
        
        item = response['Item']
        
        # Increment view counter
        current_views = int(item.get('views', 0))
        new_views = current_views + 1
        
        # Update the view count in DynamoDB
        table.update_item(
            Key={'id': cv_id},
            UpdateExpression='SET #views = :new_views',
            ExpressionAttributeNames={'#views': 'views'},
            ExpressionAttributeValues={':new_views': new_views}
        )
        
        # Update the item with new view count
        item['views'] = new_views
        
        # Log successful operation
        print(f"Successfully retrieved CV {cv_id}. Views: {new_views}")
        
        # Return success response
        return create_response(200, item)
        
    except ClientError as e:
        # Handle DynamoDB errors
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        
        print(f"DynamoDB error: {error_code} - {error_message}")
        
        return create_response(500, {
            'error': 'Database error',
            'message': 'An error occurred while accessing the database',
            'details': error_message
        })
        
    except Exception as e:
        # Handle unexpected errors
        print(f"Unexpected error: {str(e)}")
        
        return create_response(500, {
            'error': 'Internal server error',
            'message': str(e)
        })


def create_response(status_code, body):
    """
    Create a properly formatted API Gateway response with CORS headers
    
    Args:
        status_code: HTTP status code
        body: Response body (will be JSON stringified)
        
    Returns:
        dict: Formatted API Gateway response
    """
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',  # Enable CORS for all origins
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'GET,OPTIONS'
        },
        'body': json.dumps(body, ensure_ascii=False)
    }
