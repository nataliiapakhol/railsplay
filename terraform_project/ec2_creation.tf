provider "aws" {
  access_key =""
  secret_key =""
  region     = "eu-west-3"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  
  tags {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "my_vpc_subnet" {
  vpc_id                  = "${aws_vpc.my_vpc.id}"
  cidr_block              = "10.0.0.0/24"
  

tags = {
   Name = "my_vpc_subnet"
  }
}
resource "aws_security_group" "my_vpc_sg" {
  vpc_id       = "${aws_vpc.my_vpc.id}"
  name         = "my_vpc_sg"
  description  = "Allow only 3000 port"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "my_vpc_sg"
  }
}

resource "aws_instance" "railsplay" {
  ami           = "ami-0e55e373"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.my_vpc_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.my_vpc_sg.id}"]
}
