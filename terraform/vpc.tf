#VPC Creation

resource "aws_vpc" "todo-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "todo-vpc"
  }
}

#subnet Creation

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.todo-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "public-subnet"
  }
  depends_on = [aws_vpc.todo-vpc]
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.todo-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private-subnet"
  }
  depends_on = [aws_vpc.todo-vpc]
}
resource "aws_subnet" "db-subnet-1" {
  vpc_id            = aws_vpc.todo-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "db-subnet-1"
  }
  depends_on = [aws_vpc.todo-vpc]
}

resource "aws_subnet" "db-subnet-2" {
  vpc_id            = aws_vpc.todo-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "db-subnet-2"
  }
  depends_on = [aws_vpc.todo-vpc]
}

#Internet gateway
resource "aws_internet_gateway" "public-gw" {
  vpc_id = aws_vpc.todo-vpc.id
  tags = {
    Name = "public-gw"
  }
  depends_on = [aws_vpc.todo-vpc]
}

#elastic-IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
#NAT gw

resource "aws_nat_gateway" "private-gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "private-gw"
  }
}

#public route table
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.todo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public-gw.id
  }
  tags = {
    Name = "public-rtb"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rtb.id
}

#private route table
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.todo-vpc.id
  tags = {
    Name = "private-rtb"
  }
}
resource "aws_route" "private_route_to_nat" {
  route_table_id         = aws_route_table.private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private-gw.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rtb.id
}

