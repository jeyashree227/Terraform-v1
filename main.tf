
//VPC Creation
resource "aws_vpc" "terraform-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Terraform-VPC"
  }
}

//Public Subnet creation
resource "aws_subnet" "Public-Subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}

//Private Subnet creation
resource "aws_subnet" "Private-Subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet"
  }
}

//Elastic IP Creation
resource "aws_eip" "elastic-ip1" {
  vpc = true
  tags = {
    Name = "Elastic IP for web server"
  }
}


//NAT gateway creation
resource "aws_nat_gateway" "NAT_GW" {
  allocation_id = aws_eip.elastic-ip1.id
  subnet_id     = aws_subnet.Public-Subnet.id
  tags = {
    Name = "NAT-GW"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "Terraform GW"
  }
}

//Public Route Table creation
resource "aws_route_table" "Public-Route-Table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

//Private Route Table creation
resource "aws_route_table" "Private-Route-Table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0"
    nat_gateway_id = aws_nat_gateway.NAT_GW.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_nat_gateway.NAT_GW.id
  }

  tags = {
    Name = "Private-RT"
  }
}

//Public route table association
resource "aws_route_table_association" "Public" {
  subnet_id      = aws_subnet.Public-Subnet.id
  route_table_id = aws_route_table.Public-Route-Table.id
}

//Private route table association
resource "aws_route_table_association" "Private" {
  subnet_id      = aws_subnet.Private-Subnet.id
  route_table_id = aws_route_table.Private-Route-Table.id
}

//EC2-Instance creation
resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = "t2.micro"
  tags = {
      Name = "Web-Server"
  }
}

resource "aws_key_pair" "public_key" {
  key_name   = "sigaramthodu"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCctSpjg++Bjs/Xa8RKhNsB4qk1GddpFLMf62ZAkMnzu6VIvvT/L7XSWEB3q/E/Q5o77JCidktwChY3Jz5lgWZgQQB78sabMA2rLSifbwkeiSyjW/+ah7NsM6PcGATEjtEPc8zodDnXOFbqoXN+3pT00CtfH7bG8nINw5DgrcZVNWmaYNR5RAdsIenPdZwgSTgw7pG3eJslgP/SybvfpdJsuvxGgdzoKvsPSlknntgSVavG9udC9W2+pbszjte/J0ONj+iTUd8E3K+tNz5uqW1qVYbAtqHjGrXNv/UxMVkwiCpmaOUSllaKeaV3uHDZn6bJB1wNg0mWOJTwFEGSLWEj"
}
