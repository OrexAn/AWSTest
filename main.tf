terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70"
    }
  }
}

# Provider Block
provider "aws" {
  profile = "default"
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "my_test_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_test_vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[0]

  tags = {
    Name = var.public_subnet_name
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_test_vpc.id
  cidr_block = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone = var.availability_zones[0]

  tags = {
    Name = var.public_subnet_name
  }
}

# NAT Gateway for the public subnet
resource "aws_eip" "nat_gateway" {
  domain = "vpc"
  associate_with_private_ip = "10.0.0.5"
  depends_on                = [aws_internet_gateway.my_ig]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "ngw"
  }
  depends_on = [aws_eip.nat_gateway]
}

# Creates a route to the internet
resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.my_test_vpc.id

  tags = {
    Name = var.public_igw_name
  }
}

# Creates new route table with public IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
  }

  tags = {
    Name = var.public_igw_name
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.my_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

/*# Route the public subnet traffic through the Internet Gateway
resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.my_ig.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route NAT Gateway
resource "aws_route" "nat-ngw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.ngw.id
  destination_cidr_block = "0.0.0.0/0"
}*/

# Associates route table with subnet
resource "aws_route_table_association" "public-route-association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private-route-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private_subnet.id
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "./.ssh/terraform_rsa"
  file_permission = "0400"
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "./.ssh/terraform_rsa.pub"
  file_permission = "0400"
}

resource "aws_key_pair" "deployer" {
  key_name   = "ubuntu_ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Creates new security group for Ubuntu
resource "aws_security_group" "app_ubuntu_sg" {
  name = "MainUbuntuSG"
  vpc_id = aws_vpc.my_test_vpc.id

  ingress {
    description = "Allow all incoming ICMP IPv4 traffic"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creates new security group for Linux
resource "aws_security_group" "app_linux_sg" {
  name = "MainLinuxSG"
  vpc_id = aws_vpc.my_test_vpc.id

  ingress {
    description = "Allow all incoming ICMP IPv4 traffic"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all incoming ICMP IPv4 traffic"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Resources Block
resource "aws_instance" "app_server_1" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = var.ubuntu_instance_type

  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.app_ubuntu_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  depends_on = [
    aws_security_group.app_ubuntu_sg,
    aws_internet_gateway.my_ig
  ]

  user_data = <<-EOF
    #!/bin/bash -ex
    echo "${local_file.private_key.content}" > /home/ubuntu/.ssh/terraform_rsa
    chmod 600 /home/ubuntu/.ssh/terraform_rsa
    chown ubuntu:ubuntu /home/ubuntu/.ssh/terraform_rsa

    sudo apt update -y
    sudo apt install -y nginx php8.3 php8.3-fpm


    echo "<?php
    \$os_info = php_uname();
    \$disk_free_space = disk_free_space('/');
    \$disk_total_space = disk_total_space('/');

    function formatSize(\$size) {
        \$units = array('B', 'KB', 'MB', 'GB', 'TB');
        \$unit = 0;
        while (\$size >= 1024 && \$unit < 4) {
            \$size /= 1024;
            \$unit++;
        }
        return round(\$size, 2) . ' ' . \$units[\$unit];
    }

    \$server_ip = \$_SERVER['SERVER_ADDR'];

    echo '<h1>Hello World!</h1>';
    echo '<h2>Server Information</h2>';
    echo '<p><strong>Operating System:</strong> ' . \$os_info . '</p>';
    echo '<p><strong>Free Disk Space:</strong> ' . formatSize(\$disk_free_space) . '</p>';
    echo '<p><strong>Total Disk Space:</strong> ' . formatSize(\$disk_total_space) . '</p>';
    echo '<p><strong>Server IP Address:</strong> ' . \$server_ip . '</p>';
    ?>" | sudo tee /var/www/html/index.php


    sudo sed -i 's/listen 80 default_server;/listen 80 default_server;/g' /etc/nginx/sites-available/default
    sudo sed -i 's/index index.html index.htm index.nginx-debian.html;/index index.php index.html index.htm;/g' /etc/nginx/sites-available/default
    sudo sed -i 's/#location ~ \\.php$ {/location ~ \\.php$ {/g' /etc/nginx/sites-available/default
    sudo sed -i 's/#\tinclude snippets\/fastcgi-php.conf;/\tinclude snippets\/fastcgi-php.conf;/g' /etc/nginx/sites-available/default
    sudo sed -i 's/#\tfastcgi_pass unix:\/run\/php\/php7.4-fpm.sock;/\tfastcgi_pass unix:\/var\/run\/php\/php8.3-fpm.sock;\n\t}/g' /etc/nginx/sites-available/default

    sudo systemctl restart nginx

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo docker run hello-world

    sudo apt-get update
  EOF

  user_data_replace_on_change = true

  tags = {
    Name = var.ubuntu_instance_name
  }
}

resource "aws_instance" "app_server_2" {
  ami           = "ami-0fff1b9a61dec8a5f"
  instance_type = var.linux_instance_type
  subnet_id = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.app_linux_sg.id]

  key_name = aws_key_pair.deployer.key_name

  depends_on = [
    aws_instance.app_server_1
  ]

  user_data_replace_on_change = true

  tags = {
    Name = var.linux_instance_name
  }
}