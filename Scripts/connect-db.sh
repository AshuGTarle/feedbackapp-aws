#!/bin/bash
# FeedbackApp - Database Connection Script
# Run this from your Public EC2 instance to connect to MySQL on the Private EC2.

# Replace <PRIVATE_EC2_IP> with your actual private IP
mysql -h <PRIVATE_EC2_IP> -u root -p feedbackdb
