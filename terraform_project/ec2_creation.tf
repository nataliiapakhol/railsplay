#Access credentials

provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "${var.aws_region}"
}

#Create aws vpc

resource "aws_vpc" "my_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "My vpc"
  }
}

#Create aws internet gateway

resource "aws_internet_gateway" "my_gw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "My gateway"
  }
}

# Define the public subnet

resource "aws_subnet" "public_subnet" {
  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "eu-west-3a"

  tags {
    Name = "My Public Subnet"
  }
}

# Define the private subnet

resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-3b"

  tags {
    Name = "My Private Subnet"
  }
}

#Define security group for public subnet

resource "aws_security_group" "sg_public" {
  vpc_id      = "${aws_vpc.my_vpc.id}"
  name        = "my_vpc_sg_public"
  description = "Allow incoming connection with port 3000 and SSH access"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "my_vpc_sg"
  }
}

#Launch instance with specified atributes

resource "aws_instance" "railsplay_instance" {
  ami                    = "${var.ami}"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.public_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_public.id}"]
}

#Attaching a Static IP
resource "aws_eip" "my_eip" {
  instance = "${aws_instance.railsplay_instance.id}"
}
