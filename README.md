# 📘 FeedbackApp – AWS Two-Tier Architecture Project  

## 📌 Overview  
FeedbackApp is a simple **two-tier application** deployed on AWS to demonstrate core cloud concepts:  
- **Frontend Layer (Public):** A web server running on Amazon EC2, behind an Application Load Balancer.  
- **Backend Layer (Private):** A relational database (MySQL) hosted on a private EC2 instance.  
- **Networking:** Custom VPC with subnets, route tables, and an Internet Gateway.  
- **Security:** Bastion host model for SSH, security groups for isolation.  

This project showcases AWS fundamentals including **VPC design, EC2 deployment, web server hosting, database connectivity, and load balancing.**  

---

## 🏗️ Architecture  

```
Internet
   │
   ▼
Application Load Balancer (ALB)
   │
   ▼
Public Subnet (EC2 – Web Server / Bastion Host)
   │
   ▼
Private Subnet (EC2 – MySQL Database)

                         [ User Browser ]
                                │
                                ▼
                       [ Application Load Balancer ]
                                │
                         ┌──────┴──────┐
                         │             │
                  [ Public Subnet AZ1 ]  (10.0.1.0/24)
                         │
             [ Public EC2 – Web Server + Bastion ]
                         │   (SG: HTTP 80, SSH 22)
                         ▼
                  [ Private Subnet AZ1 ]  (10.0.2.0/24)
                         │
             [ Private EC2 – MySQL Database ]
                  (SG: MySQL 3306 only from Public SG)
                         
---------------------------------------------------------------
AWS Networking:
- VPC: 10.0.0.0/20
- Internet Gateway → Public Route Table → Public Subnets
- Private Route Table → only local routes (no NAT)
- VPC Endpoint (S3) → Private Subnet ↔ S3 access

```

- **VPC CIDR:** `10.0.0.0/20` (example, customizable)  
- **Subnets:**  
  - Public Subnet in each Availability Zone (AZ)  
  - Private Subnet in each AZ  
- **Routing:**  
  - Public Subnets → Internet Gateway  
  - Private Subnets → local VPC only (no direct internet)  

---

## 🔑 Phase 1: VPC & Networking Setup  

1. **Create VPC**  
   - Name: `feedbackapp-vpc`  
   - CIDR: `10.0.0.0/20`  
   - Tenancy: Default  

2. **Create Subnets** (for 2 AZs)  
   - Public Subnet 1 (e.g., `10.0.1.0/24`)  
   - Private Subnet 1 (e.g., `10.0.2.0/24`)  
   - Public Subnet 2 (e.g., `10.0.3.0/24`)  
   - Private Subnet 2 (e.g., `10.0.4.0/24`)  

3. **Attach Internet Gateway**  
   - Create IGW → Attach to VPC.  

4. **Route Tables**  
   - **Public Route Table**:  
     - Route `0.0.0.0/0` → Internet Gateway  
     - Associate with both Public Subnets  
   - **Private Route Table**:  
     - Default local VPC route only  
     - Associate with both Private Subnets  

---

## 🔒 Phase 2: Security Groups  

1. **Public SG – `feedbackapp-sg-public`**  
   - Inbound:  
     - HTTP (80) → Anywhere  
     - SSH (22) → Your IP (for testing, not `0.0.0.0/0` in production)  
   - Outbound: Allow All  

2. **Private SG – `feedbackapp-sg-private`**  
   - Inbound:  
     - MySQL (3306) → Source = Public SG  
   - Outbound: Allow All  

---

## 💻 Phase 3: EC2 Setup  

### Public EC2 (Web Server + Bastion)  
1. Launch EC2 in **Public Subnet**.  
   - Amazon Linux 2023 (Free Tier eligible)  
   - Key Pair: `feedbackapp-key.pem`  
   - Public IP enabled  
   - Security Group: `feedbackapp-sg-public`  

2. Install Apache Web Server:  
   ```bash
   sudo dnf update -y
   sudo dnf install -y httpd
   sudo systemctl start httpd
   sudo systemctl enable httpd
   ```

3. Add test webpage:  
   ```bash
   echo "<h1>Welcome to FeedbackApp Project - Web Server on AWS</h1>" | sudo tee /var/www/html/index.html
   ```

4. Verify in browser with **Public EC2 IP**:  
   - Should display the welcome message.  

---

### Private EC2 (MySQL Database)  
1. Launch EC2 in **Private Subnet**.  
   - Amazon Linux 2023  
   - No Public IP  
   - Security Group: `feedbackapp-sg-private`  

2. SSH Access (via Bastion):  
   - From laptop → SSH into Public EC2  
   - From Public EC2 → SSH into Private EC2  

3. Install MySQL Server:  
   ```bash
   sudo dnf update -y
   sudo dnf install -y mariadb105-server
   sudo systemctl start mariadb
   sudo systemctl enable mariadb
   ```

4. Secure MySQL:  
   ```bash
   sudo mysql_secure_installation
   ```
   - Remove anonymous users → Yes  
   - Disallow root login remotely → Yes  
   - Remove test DB → Yes  
   - Reload privilege tables → Yes  

5. Create Database (example):  
   ```sql
   CREATE DATABASE feedbackdb;
   USE feedbackdb;
   CREATE TABLE feedback (
       id INT AUTO_INCREMENT PRIMARY KEY,
       name VARCHAR(100),
       comment TEXT
   );
   ```

---

## 🔗 Phase 4: Connectivity Test  

From **Public EC2 (Web Server)** → Connect to **Private EC2 MySQL**:  
```bash
mysql -h <PRIVATE_EC2_IP> -u root -p
```

✅ Successful connection proves **public EC2 ↔ private EC2** communication works.  

---

## ⚖️ Phase 5: Load Balancer  

1. Create **Target Group**  
   - Type: Instances  
   - Targets: Public EC2(s)  

2. Create **Application Load Balancer (ALB)**  
   - Scheme: Internet-facing  
   - Listener: HTTP (80) → Target Group  

3. Verify  
   - Copy ALB DNS name (e.g., `http://<ALB-DNS>`)  
   - Open in browser → FeedbackApp webpage loads.  

---

## 📌 Next Steps (Future Enhancements)  
- Replace Private EC2 MySQL with **Amazon RDS** (managed DB).  
- Add **S3 Bucket** (for logs or static assets).  
- Add **Auto Scaling Group** (for web servers).  
- Infrastructure as Code (Terraform or CloudFormation).  
