-- FeedbackApp - Database Setup Script
-- Run this inside MySQL on the Private EC2 instance.

-- Create database
CREATE DATABASE feedbackdb;

-- Switch to database
USE feedbackdb;

-- Create feedback table
CREATE TABLE feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    comment TEXT
);

-- Insert test data
INSERT INTO feedback (name, comment) VALUES
('Alice', 'Great project!'),
('Bob', 'Learning AWS is fun.');
