##################################################################################
#### Terraform Template creates AWS infrastructure
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
resource "aws_vpc" "master_vpc" {
    cidr_block = var.cidr_block
    tags = {
        Name:  "${var.env_prefix}-master-vpc"
    }
}


#### Create subnet
resource "aws_subnet" "master_public_subnet" {
  vpc_id = aws_vpc.master_vpc.id
  cidr_block = var.public_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-master-public-subnet"
  }
}

#### Create Internet Gateway
resource "aws_internet_gateway" "master_internet_gateway" {
  vpc_id = aws_vpc.master_vpc.id
  tags = {
    Name: "${var.env_prefix}-master-internet-gateway"
  }
}

#### Create Public Routing table
resource "aws_route_table" "master_public_route_table" {
  vpc_id = aws_vpc.master_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.master_internet_gateway.id
  }
  tags = {
    Name: "${var.env_prefix}-master-public-route-table"
  }
}
resource "aws_route_table_association" "master_public_route_association" {
  subnet_id = aws_subnet.master_public_subnet.id
  route_table_id = aws_route_table.master_public_route_table.id
}



#### Create Security Groups
resource "aws_security_group" "master_ingress_sec_group" {
#  name = "master_ingress_sec_group"
  vpc_id = aws_vpc.master_vpc.id
# SSH  ungress rule
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTP ingress rule for Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTP ingress rule for Nexus repository manager
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
    Name: "${var.env_prefix}-master-sg"
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

resource "aws_instance" "master-host" {
  ami =  data.aws_ami.latest-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.master_public_subnet.id
  vpc_security_group_ids = [aws_security_group.master_ingress_sec_group.id]
  availability_zone = var.avail_zone
  key_name = var.keyname
  associate_public_ip_address = true
  tags = {
    Name: "${var.env_prefix}-master-host"
  }
  user_data = file("init-master.sh")
}