terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
   access_key = "tt" # keys.my-access-key
   secret_key = "tttt" #keys.my-secret-key
}

# Creating resources 
# Creating vpc
resource "aws_vpc" "RH_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sandbox-vpc"
  }
}
# creating subnet for vpc
resource "aws_subnet" "RH_subnet" {
  vpc_id = aws_vpc.RH_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "RH-subnet"
  }
}
# Creating Internet Gateway
resource "aws_internet_gateway" "RH_igw" {
  vpc_id = aws_vpc.RH_vpc.id

  tags = { 
    Name = "RH_igw"
  }
}
# creating route table
resource "aws_route_table" "RH_route_table" {
  vpc_id = aws_vpc.RH_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.RH_igw.id
  }
  tags = {
    Name = "RH-route-table"
  }
}
# Route Table associating
resource "aws_route_table_association" "RH_route_table_association" {
  subnet_id = aws_subnet.RH_subnet.id
  route_table_id = aws_route_table.RH_route_table.id
}
# Creating Security Group
resource "aws_security_group" "RH_sg" {
  vpc_id = aws_vpc.RH_vpc.id

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
    Name = "RH-sg"
  }
}

# associating the key pair 
resource "aws_key_pair" "developer_key" {
  key_name = "developer_key"
  public_key = file("~/.ssh/new_key.pub")
}

# creating aws instance VM
resource "aws_instance" "developer_vm" {
  ami     = "ami-0606dd43116f5ed57"
  instance_type    = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.RH_subnet.id
  vpc_security_group_ids = [aws_security_group.RH_sg.id]
  key_name = aws_key_pair.developer_key.key_name
   
  tags = {
    Name = "developer-vm"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/new_key")
    host        = self.public_ip
  }

  provisioner "local-exec" {
  command = "sleep 120; ansible-playbook -i '${self.public_ip},' -u ubuntu --private-key ~/.ssh/new_key ${path.module}/playbook.yml "
  }
}
# print the public ip of VM
output "name" {
  value = aws_instance.developer_vm.public_ip
}
