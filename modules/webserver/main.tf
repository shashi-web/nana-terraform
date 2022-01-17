
resource "aws_key_pair" "ssh-key" {
  key_name   = "myapp-key"
  public_key = "${file(var.my_public_key)}"
}

resource "aws_security_group" "myapp-sg" {
  name        = "myapp-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH to EC2"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  availability_zone = var.az
  key_name = aws_key_pair.ssh-key.key_name
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]

  user_data = <<EOF
            #! /bin/bash
            sudo yum update
            sudo yum install docker -y
            sudo systemctl start docker
            usermod -aG docker ec2-user
            docker run -p 8080:8080 nginx
            EOF

  tags = {
    Name = "${var.env_prefix}-server"
  }
}