provider "aws" {
  region     = us-east-1
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "myapp-key"
  public_key = "${file(var.my_public_key)}"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.az

  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}
