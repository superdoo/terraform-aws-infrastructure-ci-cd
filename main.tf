provider "aws" {
  region = "us-west-2"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = "ami-04f5a6a7ecc99fbe2" # Ubuntu AMI for us-west-2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "WebServer"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main_db_subnet_group" {
  name        = "main-db-subnet-group"
  subnet_ids  = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  description = "Main DB Subnet Group"

  tags = {
    Name = "Main DB Subnet Group"
  }
}

# RDS Instance
resource "aws_db_instance" "my_database" {
  allocated_storage    = 20
  instance_class       = "db.t3.micro"
  engine               = "mysql"
  engine_version       = "8.0.35"
  db_name              = "mydb"
  username             = "admin"
  password             = "mypassword"
  db_subnet_group_name = aws_db_subnet_group.main_db_subnet_group.id
  skip_final_snapshot  = true

  tags = {
    Name = "MyDatabase"
  }
}


# Load Balancer
resource "aws_lb" "main_lb" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]

  enable_deletion_protection = false

  tags = {
    Name = "main-lb"
  }
}

# Optional: Route 53 DNS record (uncomment and replace with your real zone_id and domain)
# resource "aws_route53_record" "main_lb_dns" {
#   zone_id = "YOUR_ZONE_ID"
#   name    = "mywebsite.example.com"
#   type    = "A"
#   alias {
#     name                   = aws_lb.main_lb.dns_name
#     zone_id                = aws_lb.main_lb.zone_id
#     evaluate_target_health = true
#   }
# }
