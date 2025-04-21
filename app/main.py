from flask import Flask, render_template, request, jsonify
import boto3
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

# AWS Configuration - Using IRSA (no credentials needed)
sqs = boto3.client('sqs', region_name=os.getenv('AWS_REGION'))
sns = boto3.client('sns', region_name=os.getenv('AWS_REGION'))

# Get queue URLs from environment variables
SQS_QUEUE_URL = os.getenv('SQS_QUEUE_URL')
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')

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

        # Send message to SQS
        message = {
            'firstName': first_name,
            'lastName': last_name,
            'email': email
        }
        
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=str(message)
        )

        # Publish to SNS
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"New registration: {first_name} {last_name}",
            Subject="New User Registration"
        )

        # Store first three subscribers
        if len(first_three_subscribers) < 3:
            first_three_subscribers.append({
                'firstName': first_name,
                'lastName': last_name,
                'email': email
            })

        return jsonify({'status': 'success', 'message': 'Form submitted successfully'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/messages')
def get_messages():
    try:
        # Return the first three subscribers
        return jsonify({'messages': first_three_subscribers})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
