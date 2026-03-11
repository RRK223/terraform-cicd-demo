# Configure Terraform settings
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider - explicitly use environment variables
provider "aws" {
  region = var.aws_region

  # These will be picked up from environment variables
  # No need to hardcode anything here

  # Optional: Add retry logic for transient errors
  max_retries = 3
}

# Data source to get default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group for EC2
resource "aws_security_group" "app_sg" {
  name        = "docker-app-sg-${formatdate("YYYYMMDDhhmm", timestamp())}"
  description = "Security group for Docker app"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker-app-sg"
  }
}

# Look up the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Use user data to install Docker and run app
  user_data = <<-EOF
    #!/bin/bash
    set -ex
    
    # Update system
    sudo dnf update -y
    
    # Install Docker
    sudo dnf install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -a -G docker ec2-user
    
    # Create app directory
    mkdir -p /home/ec2-user/app
    
    # Create a simple web app
    cat > /home/ec2-user/app/index.html << 'END'
<!DOCTYPE html>
<html>
<head>
    <title>Deployed via Terraform CI/CD</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; }
        .container { padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 10px; }
        h1 { font-size: 2.5em; }
        .info { background: rgba(255,255,255,0.1); padding: 10px; border-radius: 5px; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Deployment Successful!</h1>
        <p>Deployed with Terraform + GitHub Actions</p>
        <div class="info">
            <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
            <p><strong>Instance Type:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-type)</p>
            <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Deployment Time:</strong> $(date)</p>
        </div>
    </div>
</body>
</html>
END

    # Create Dockerfile
    cat > /home/ec2-user/app/Dockerfile << 'END'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
END

    # Build and run Docker container
    cd /home/ec2-user/app
    sudo docker build -t myapp:latest .
    sudo docker run -d --name myapp -p 80:80 --restart unless-stopped myapp:latest
    
    echo "Setup complete!" > /home/ec2-user/setup.log
  EOF

  tags = {
    Name = "terraform-docker-app"
  }
}

# Output the public IP
output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "app_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.app_server.public_ip}"
}

# Optional: Output the AMI ID used
output "ami_used" {
  description = "AMI ID used for the instance"
  value       = data.aws_ami.amazon_linux_2023.id
}
