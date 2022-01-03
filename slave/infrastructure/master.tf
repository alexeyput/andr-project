##################################################################################
#### Terraform Template creates AWS infrastructure for the Final project
#### To check what will be created:
#### terraform plan
#### To create:
#### terraform apply --auto-approve
#### To destroy:
#### terraform destroy --auto-approve
##################################################################################

provider "aws" {
  region = "${var.aws_region}"
}

# Create VPC
resource "aws_vpc" "project_vpc" {
    cidr_block = var.cidr_block
    tags = {
        Name:  "${var.env_prefix}-project-vpc"
    }
}

#### Create subnet
resource "aws_subnet" "project_public_subnet" {
  vpc_id = aws_vpc.project_vpc.id
  cidr_block = var.public_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-project-public-subnet"
  }
}

#### Create Internet Gateway
resource "aws_internet_gateway" "project_internet_gateway" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name: "${var.env_prefix}-project-internet-gateway"
  }
}

#### Create Public Routing table
resource "aws_route_table" "project_public_route_table" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_internet_gateway.id
  }
  tags = {
    Name: "${var.env_prefix}-project-public-route-table"
  }
}
resource "aws_route_table_association" "project_public_route_association" {
  subnet_id = aws_subnet.project_public_subnet.id
  route_table_id = aws_route_table.project_public_route_table.id
}



#### Create Security Groups
resource "aws_security_group" "project_ingress_sec_group" {
#  name = "project_ingress_sec_group"
  vpc_id = aws_vpc.project_vpc.id
# SSH  ungress rule
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTP ingress rule Python App
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTP ingress rule Java App
  ingress {
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name: "${var.env_prefix}-project-sg"
  }
}

#### Create Public Ec2 instances
data "aws_ami" "latest-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "project-host" {
  ami =  data.aws_ami.latest-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.project_public_subnet.id
  vpc_security_group_ids = [aws_security_group.project_ingress_sec_group.id]
  availability_zone = var.avail_zone
  key_name = var.keyname
  associate_public_ip_address = true
  tags = {
    Name: "${var.env_prefix}-project-host"
  }
  user_data = file("init-project.sh")
}