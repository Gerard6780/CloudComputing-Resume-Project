"""
Unit tests for Lambda handler
Uses pytest with monkeypatch to mock DynamoDB interactions
"""

import json
import pytest
from unittest.mock import MagicMock, patch
import sys
import os

# Add lambda directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'lambda'))

from handler import lambda_handler, create_response


class TestLambdaHandler:
    """Test suite for Lambda handler function"""
    
    def test_create_response_success(self):
        """Test that create_response formats responses correctly"""
        response = create_response(200, {'message': 'success'})
        
        assert response['statusCode'] == 200
        assert 'Access-Control-Allow-Origin' in response['headers']
        assert response['headers']['Access-Control-Allow-Origin'] == '*'
        assert json.loads(response['body']) == {'message': 'success'}
    
    def test_missing_id_parameter(self):
        """Test handler returns 400 when id parameter is missing"""
        event = {
            'queryStringParameters': None
        }
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 400
        body = json.loads(response['body'])
        assert 'error' in body
        assert 'id' in body['message'].lower()
    
    def test_empty_query_parameters(self):
        """Test handler returns 400 when query parameters are empty"""
        event = {
            'queryStringParameters': {}
        }
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 400
        body = json.loads(response['body'])
        assert body['error'] == 'Missing required parameter: id'
    
    @patch('handler.table')
    def test_cv_not_found(self, mock_table):
        """Test handler returns 404 when CV doesn't exist"""
        # Mock DynamoDB response with no item
        mock_table.get_item.return_value = {}
        
        event = {
            'queryStringParameters': {'id': 'nonexistent'}
        }
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 404
        body = json.loads(response['body'])
        assert 'not found' in body['error'].lower()
    
    @patch('handler.table')
    def test_successful_cv_retrieval(self, mock_table):
        """Test successful CV retrieval and view increment"""
        # Mock DynamoDB get_item response
        mock_table.get_item.return_value = {
            'Item': {
                'id': 'portfolio1',
                'name': 'Test Portfolio',
                'views': 10
            }
        }
        
        # Mock update_item (no return needed)
        mock_table.update_item.return_value = {}
        
        event = {
            'queryStringParameters': {'id': 'portfolio1'}
        }
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert body['id'] == 'portfolio1'
        assert body['views'] == 11  # Incremented from 10 to 11
        
        # Verify update_item was called
        mock_table.update_item.assert_called_once()
    
    @patch('handler.table')
    def test_view_counter_starts_at_zero(self, mock_table):
        """Test view counter initializes to 1 when not present"""
        # Mock DynamoDB response without views field
        mock_table.get_item.return_value = {
            'Item': {
                'id': 'portfolio1',
                'name': 'Test Portfolio'
            }
        }
        
        mock_table.update_item.return_value = {}
        
        event = {
            'queryStringParameters': {'id': 'portfolio1'}
        }
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert body['views'] == 1  # Started at 0, incremented to 1
    
    @patch('handler.table')
    def test_dynamodb_client_error(self, mock_table):
        """Test handler handles DynamoDB errors gracefully"""
        from botocore.exceptions import ClientError
        
        # Mock DynamoDB error
        error_response = {
            'Error': {
                'Code': 'ResourceNotFoundException',
                'Message': 'Table not found'
            }
        }
        mock_table.get_item.side_effect = ClientError(error_response, 'GetItem')
        
        event = {
            'queryStringParameters': {'id': 'portfolio1'}
        }
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 500
        body = json.loads(response['body'])
        assert 'error' in body
        assert 'Database error' in body['error']
    
    @patch('handler.table')
    def test_unexpected_error(self, mock_table):
        """Test handler handles unexpected errors"""
        # Mock unexpected error
        mock_table.get_item.side_effect = Exception('Unexpected error')
        
        event = {
            'queryStringParameters': {'id': 'portfolio1'}
        }
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 500
        body = json.loads(response['body'])
        assert 'error' in body
    
    def test_cors_headers_present(self):
        """Test that CORS headers are present in all responses"""
        response = create_response(200, {})
        
        assert 'Access-Control-Allow-Origin' in response['headers']
        assert 'Access-Control-Allow-Headers' in response['headers']
        assert 'Access-Control-Allow-Methods' in response['headers']


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
