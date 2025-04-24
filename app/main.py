from flask import Flask, render_template, request, jsonify
import boto3
import os
import logging
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

app = Flask(__name__)

# AWS Configuration - Using IRSA (no credentials needed)
AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')  # Default to us-east-1 if not set
logger.info(f"Initializing AWS clients with region: {AWS_REGION}")

try:
    logger.info("Attempting to initialize SQS client...")
    sqs = boto3.client('sqs', region_name=AWS_REGION)
    logger.info("SQS client initialized successfully")
    
    logger.info("Attempting to initialize SNS client...")
    sns = boto3.client('sns', region_name=AWS_REGION)
    logger.info("SNS client initialized successfully")
except Exception as e:
    logger.error(f"Error initializing AWS clients: {e}")
    sqs = None
    sns = None

# Get queue URLs from environment variables
SQS_QUEUE_URL = os.getenv('SQS_QUEUE_URL')
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')

logger.info(f"SQS Queue URL: {SQS_QUEUE_URL}")
logger.info(f"SNS Topic ARN: {SNS_TOPIC_ARN}")

# Store the first three subscribers
first_three_subscribers = []

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/submit', methods=['POST'])
def submit_form():
    try:
        first_name = request.form['firstName']
        last_name = request.form['lastName']
        email = request.form['email']

        logger.info(f"Received form submission for: {first_name} {last_name}")

        # Send message to SQS
        message = {
            'firstName': first_name,
            'lastName': last_name,
            'email': email
        }
        
        if sqs is None:
            logger.error("SQS client is not initialized")
            raise Exception("SQS client is not initialized")
        
        logger.info(f"Attempting to send message to SQS: {message}")
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=str(message)
        )
        logger.info("Message sent to SQS successfully")

        # Publish to SNS
        if sns is None:
            logger.error("SNS client is not initialized")
            raise Exception("SNS client is not initialized")
        
        logger.info(f"Attempting to publish to SNS topic: {SNS_TOPIC_ARN}")
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"New registration: {first_name} {last_name}",
            Subject="New User Registration"
        )
        logger.info("Message published to SNS successfully")

        # Store first three subscribers
        if len(first_three_subscribers) < 3:
            first_three_subscribers.append({
                'firstName': first_name,
                'lastName': last_name,
                'email': email
            })
            logger.info(f"Added subscriber to local storage. Total subscribers: {len(first_three_subscribers)}")
            return jsonify({
                'status': 'success', 
                'message': 'Congratulations! You are one of the first three subscribers and have won a special gift!'
            })
        else:
            return jsonify({
                'status': 'success', 
                'message': 'Thank you for subscribing! Unfortunately, you were not among the first three subscribers to receive a gift.'
            })
    except Exception as e:
        logger.error(f"Error processing form submission: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/messages')
def get_messages():
    try:
        logger.info("Retrieving stored messages")
        return jsonify({'messages': first_three_subscribers})
    except Exception as e:
        logger.error(f"Error retrieving messages: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
