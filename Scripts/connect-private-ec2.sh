#!/bin/bash
# FeedbackApp - Connect to Private EC2 (via Bastion Host)
# Step 1: SSH into Public EC2 first.
# Step 2: From inside Public EC2, run this command:

ssh -i feedbackapp-key.pem ec2-user@<PRIVATE_EC2_IP>
