provider "aws" {
  region = "eu-west-1"
}

variable "env" {
  type    = string
  default = "dev"
}
variable "projectName" {
  type    = string
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "${var.env}-vpc"
    Name = "${var.projectName}-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-igw"
    Name = "${var.projectName}-igw"
  }
}

# Subnets
## Public
### AZ1
resource "aws_subnet" "subnet-public-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "${var.env}-subnet-public-1"
    Name = "${var.projectName}-subnet-public-1"
  }
}

### AZ2
resource "aws_subnet" "subnet-public-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "${var.env}-subnet-public-2"
    Name = "${var.projectName}-subnet-public-2"
  }
}

### AZ3
resource "aws_subnet" "subnet-public-3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1c"
  tags = {
    Name = "${var.env}-subnet-public-3"
    Name = "${var.projectName}-subnet-public-3"
  }
}

## Private
### AZ1
resource "aws_subnet" "subnet-private-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "${var.env}-subnet-private-1"
    Name = "${var.proectName}-subnet-private-1"
  }
}

### AZ2
resource "aws_subnet" "subnet-private-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "${var.env}-subnet-private-2"
    Name = "${var.projectName}-subnet-private-2"
  }
}

### AZ3
resource "aws_subnet" "subnet-private-3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-1c"
  tags = {
    Name = "${var.env}-subnet-private-3"
    Name = "${var.projectName}-subnet-private-3"
  }
}
/*
# Nat Instance
resource "aws_instance" "nat" {
  ami                    = "ami-0f630a3f40b1eb0b8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-public-1.id
  vpc_security_group_ids = [aws_security_group.allow_nat.id]
  source_dest_check      = "false"

  user_data = <<-EOF
        #!/bin/bash
        sysctl -w net.ipv4.ip_forward=1 /sbin/
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF

  tags = {
    Name = "${var.env}-NatInstance"
    Name = "${var.projectName}-NatInstance"
  }
}

# Nat SG
resource "aws_security_group" "allow_nat" {
  name        = "allow_web"
  vpc_id      = aws_vpc.vpc.id
  description = "Allow inbound traffic"
}

## SG Rule egress
resource "aws_security_group_rule" "web_egress_allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_nat.id
}

## SG Rule ingress
resource "aws_security_group_rule" "ingress_allow_private" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  security_group_id = aws_security_group.allow_nat.id
}
*/
# Route Table
## Private
### Use Main Route Table
resource "aws_default_route_table" "main-private" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
/*
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }
*/
  tags = {
    Name = "${var.env}-rt-main-private"
    Name = "${var.projectName}-rt-main-private"
  }
}

## Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env}-rt-public"
    Name = "${var.projectName}-rt-public"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.subnet-public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.subnet-public-2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-3" {
  subnet_id      = aws_subnet.subnet-public-3.id
  route_table_id = aws_route_table.public.id
}
terraform {
  backend "s3"{
  }
}
