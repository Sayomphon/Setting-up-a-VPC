provider "aws" {
  region = "ap-southeast-1" # Change to your preferred region
}

# Task 1: Creating the VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app-igw"
  }
}

# Task 2: Creating subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.1.0/24"
 availability_zone = "ap-southeast-2a" # Change according to your preference
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "ap-southeast-2b" # Change according to your preference
  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "ap-southeast-2a" # Change according to your preference
  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "ap-southeast-2b" # Change according to your preference
  tags = {
    Name = "Private Subnet 2"
  }
}

# Auto-assign public IP for public subnets
resource "aws_subnet_public_ip" "public_subnet_1_auto_assign" {
  subnet_id = aws_subnet.public_subnet_1.id
  map_public_ip_on_launch = true
}

resource "aws_subnet_public_ip" "public_subnet_2_auto_assign" {
  subnet_id = aws_subnet.public_subnet_2.id
  map_public_ip_on_launch = true
}

# Task 3: Creating route tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app-routetable-public"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app_igw.id
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app-routetable-private"
  }
}

# Private subnets association
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Task 4: Launching an EC2 instance
resource "aws_security_group" "web_security_group" {
  name        = "web-security-group"
  description = "Enable HTTP access"
  vpc_id     = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "employee_directory_app" {
  ami                    = "ami-0abcdef1234567890" # Replace with the correct AMI for Amazon Linux 2023
  instance_type         = "t2.micro"
  key_name              = "app-key-pair" # Replace with your key pair name
  subnet_id             = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.web_security_group.id]

  user_data = <<-EOF
                #!/bin/bash -ex
                wget https://aws-tc-largeobjects.s3-ap-southeast-1.amazonaws.com/DEV-AWS-MO-GCNv2/FlaskApp.zip
                unzip FlaskApp.zip
                cd FlaskApp/
                yum -y install python3-pip
                pip install -r requirements.txt
                yum -y install stress
                export PHOTOS_BUCKET=${SUB_PHOTOS_BUCKET}
                export AWS_DEFAULT_REGION=ap-southeast-1 
                export DYNAMO_MODE=on
                FLASK_APP=application.py /usr/local/bin/flask run --host=0.0.0.0 --port=80
                EOF

  tags = {
    Name = "employee-directory-app"
  }

  # To stop the instance to prevent future costs:
  lifecycle {
    prevent_destroy = true
  }
}