
#VPC
resource "aws_vpc" "sample-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "sample-vpc"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "sample-igw" {
  vpc_id = aws_vpc.sample-vpc.id

  tags = {
    Name = "sample-igw"
  }
}

#Route Table
resource "aws_route_table" "sample-route-table" {
  vpc_id = aws_vpc.sample-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "sample-igw"
  }

  tags = {
    Name = "sample-route-table"
  }
}




#Subnets

resource "aws_subnet" "sample-private-subnet" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "sample-private-subnet"
  }
}


resource "aws_subnet" "sample-public-subnet" {
  vpc_id                  = aws_vpc.sample-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sample-public-subnet"
  }
}





#Network ACLs
resource "aws_network_acl" "sample-acl" {
  vpc_id     = aws_vpc.sample-vpc.id
  subnet_ids = [aws_subnet.sample-public-subnet.id, aws_subnet.sample-private-subnet.id]

  ingress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }
}

#Security Groups
resource "aws_security_group" "sample-load-balancer-sg" {
  name   = "sample-load-balancer-sg"
  vpc_id = aws_vpc.sample-vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 53
    to_port          = 53
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



#Network Interface
resource "aws_network_interface" "sample-eni-1a" {
  subnet_id         = aws_subnet.sample-public-subnet.id
  private_ips       = ["10.0.1.191"]
  security_groups   = [aws_security_group.sample-load-balancer-sg.id]
  source_dest_check = true
}

resource "aws_network_interface" "sample-eni-1b" {
  subnet_id         = aws_subnet.sample-public-subnet.id
  private_ips       = ["10.0.1.18"]
  security_groups   = [aws_security_group.sample-load-balancer-sg.id]
  source_dest_check = true
}

resource "aws_network_interface" "sample-eni-1c" {
  subnet_id         = aws_subnet.sample-public-subnet.id
  private_ips       = ["10.0.1.229"]
  security_groups   = [aws_security_group.sample-load-balancer-sg.id]
  source_dest_check = true
}

resource "aws_network_interface" "sample-eni-2a" {
  subnet_id         = aws_subnet.sample-private-subnet.id
  private_ips       = ["10.0.0.172"]
  security_groups   = [aws_security_group.sample-load-balancer-sg.id]
  source_dest_check = true
  tags = {
    cluster = "sample-cluster"
    service = "sample-service"
  }
}



resource "aws_network_interface" "sample-eni-2b" {
  subnet_id         = aws_subnet.sample-private-subnet.id
  private_ips       = ["10.0.0.82"]
  security_groups   = [aws_security_group.sample-load-balancer-sg.id]
  source_dest_check = true
}

resource "aws_network_interface" "sample-eni-2c" {
  subnet_id         = aws_subnet.sample-private-subnet.id
  private_ips       = ["10.0.0.135"]
  security_groups   = [aws_security_group.sample-load-balancer-sg.id]
  source_dest_check = true
}

#Route Table Associations
resource "aws_route_table_association" "sample-rt-association-1" {
  route_table_id = aws_route_table.sample-route-table
  subnet_id      = aws_subnet.sample-public-subnet.id
}

resource "aws_route_table_association" "sample-rt-association-2" {
  route_table_id = aws_route_table.sample-route-table
  subnet_id      = aws_subnet.sample-private-subnet.id
}




