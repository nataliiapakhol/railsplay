#Access credentials

provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "${var.aws_region}"
}

#Create aws vpc

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "VPC_np"
  }
}

#Internet gateway for the public subnet

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "igw_np"
  }
}

#Elastic IP for NAT

resource "aws_eip" "nat_eip" {
  vpc = true
}

#NAT gateway 

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"

  tags {
    Name = "nat_np"
  }
}

#Define public subnet

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  availability_zone       = "${var.availability_zone}"
  map_public_ip_on_launch = true

  tags {
    Name = "public-subnet_np"
  }
}

#Define private subnet

resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.private_subnet_cidr}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.availability_zone}"

  tags {
    Name = "private-subnet_np"
  }
}

#Define routing table for private subnet

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "private-route-table_np"
  }
}

# Define routing table for public subnet

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "public-route-table_np"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

# Route table associations
resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private.id}"
}

# Define security group for the bastion host instance

resource "aws_security_group" "bastion" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "bastion-host"
  description = "Allow SSH to bastion host"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["217.20.170.129/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "bastion-sg"
  }
}

#Launch the bastion instance

resource "aws_instance" "bastion" {
  ami                    = "ami-1960d164"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  subnet_id              = "${aws_subnet.public_subnet.id}"

  tags {
    Name = "bastion_np"
  }
}

#Attaching a EIP to bastion host
resource "aws_eip" "bastion_eip" {
  instance = "${aws_instance.bastion.id}"
}

#Creating policy for the opsworks stack
resource "aws_iam_role_policy" "opsworks" {
  name = "opsworks-role-policy"
  role = "${aws_iam_role.opsworks.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "opsworks" {
  name = "opsworks-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "opsworks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM profile
resource "aws_iam_instance_profile" "opsworks" {
  name  = "opsworks"
  role = "${aws_iam_role.opsworks.name}"
}

# Create AWS OpsWorks Stack
resource "aws_opsworks_stack" "main" {
  name                         = "ssh-bastion-stack-np"
  region                       = "eu-west-3"
  service_role_arn             = "${aws_iam_role.opsworks.arn}"
  default_instance_profile_arn = "${aws_iam_instance_profile.opsworks.arn}"
  vpc_id                       = "${aws_vpc.vpc.id}"
  default_subnet_id            = "${aws_subnet.public_subnet.id}"
}

