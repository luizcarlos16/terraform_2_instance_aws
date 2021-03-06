#main.tf

variable "aws_access_key" {}
variable "aws_secret_key" {}

#CREDENTIALS
provider "aws" {
	region = "us-east-2"
}

#VPC FOR NETWORK
resource "aws_vpc" "terraformVPC" {
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    cidr_block = "10.3.0.0/16"
    tags = {
        Name = "terraformVPC"
    }
}

#SUBNET PUBLIC 
resource "aws_subnet" "terraformsn-public" {
    vpc_id = aws_vpc.terraformVPC.id
    cidr_block = "10.3.10.0/24"
    availability_zone = "us-east-2a"
    tags = {
        Name = "terraformsn-public"
    }
}

#SUBNET PRIVATE
resource "aws_subnet" "terraformsn-private" {
    vpc_id = aws_vpc.terraformVPC.id
    cidr_block = "10.3.100.0/24"
    availability_zone = "us-east-2b"
    tags = {
        Name = "terraformsn-private"
    }
}

#ROUTE TABLE FOR PUBLIC SUBNET
resource "aws_route_table" "terraform-public-rt" {
    vpc_id = aws_vpc.terraformVPC.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terragatwey.id
    }
    tags = {
        Name = "terraform-public-rt"
    }
}

#ROUTE TABLE FOR PRIVATE SUBNET
resource "aws_route_table" "terraform-private-rt" {
    vpc_id = aws_vpc.terraformVPC.id
    tags = {
        Name = "terraform-private-rt"
    }
}

#ROUTE TABLE ASSOCIATION FOR PUBLIC SUBNET
resource "aws_route_table_association" "terrafomr-public-rta" {
    subnet_id = aws_subnet.terraformsn-public.id
    route_table_id = aws_route_table.terraform-public-rt.id
}

#ROUTE TABLE ASSOCIATION FOR PRIVATE SUBNET
resource "aws_route_table_association" "terrafomr-private-rta" {
    subnet_id = aws_subnet.terraformsn-private.id
    route_table_id = aws_route_table.terraform-private-rt.id
}

#NAT GATEWAY FOR CONNECT SUBNET PRIVATE WITH INTERNET
resource "aws_nat_gateway" "terraformGW-nat" {
    allocation_id = aws_eip.terraform-nat-eip.id
    subnet_id = aws_subnet.terraformsn-public.id
    depends_on = [aws_internet_gateway.terragatwey]
}

#ASSIGN EIP FOR NAT GATEWAY
resource "aws_eip" "terraform-nat-eip" {
    vpc = "true"
    depends_on = [aws_internet_gateway.terragatwey]    
}

#GATEWAY
resource "aws_internet_gateway" "terragatwey" {
    vpc_id = aws_vpc.terraformVPC.id
    tags = {
      Name = "terragatwey"
    }
}

#SECURITY GROUP CONTROLS THE TRAFFIC
resource "aws_security_group" "terraformSG" {
  name = "terraformSG"
  vpc_id = aws_vpc.terraformVPC.id

  # INBOUND
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #OUTBOUND
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraformSG"
  }
}

#INSTANCE TESTE A
resource "aws_instance" "A" {
  ami = "ami-0996d3051b72b5b2c"
  instance_type = "t2.micro"
  disable_api_termination = "true"
  key_name = "terraform"
  vpc_security_group_ids = [aws_security_group.terraformSG.id]
  subnet_id = aws_subnet.terraformsn-public.id
  associate_public_ip_address = "true"
  tags = {
	Name = "srv-teste_a"
  }
}

#INSTANCE TESTE B
resource "aws_instance" "B" {
  ami = "ami-0996d3051b72b5b2c"
  instance_type = "t2.micro"
  disable_api_termination = "true"
  key_name = "terraform"
  vpc_security_group_ids = [aws_security_group.terraformSG.id]
  subnet_id = aws_subnet.terraformsn-public.id
  associate_public_ip_address = "true"
  tags = {
	Name = "srv-teste_b"
  }
}