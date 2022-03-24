resource "aws_vpc" "vpc" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name

  tags = {
    Name = "petclinic-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  availability_zone       = "us-east-1a"
  cidr_block              = "172.20.10.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true # This makes the subnet public

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  availability_zone = "us-east-1a"
  cidr_block        = "172.20.20.0/24"
  vpc_id            = aws_vpc.vpc.id

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    # Associated subet can reach public internet
    cidr_block = "0.0.0.0/0"

    # Which internet gateway to use
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-custom-rtb"
  }
}

resource "aws_route_table_association" "custom-rtb-public-subnet" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}