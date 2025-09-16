#!/bin/bash
# FeedbackApp - Connect to Public EC2
# Run this from your laptop/desktop terminal.

# Replace <KEY_PATH> with path to your PEM key file
# Replace <PUBLIC_EC2_IP> with your Public EC2 address

ssh -i <KEY_PATH>/feedbackapp-key.pem ec2-user@<PUBLIC_EC2_IP>
