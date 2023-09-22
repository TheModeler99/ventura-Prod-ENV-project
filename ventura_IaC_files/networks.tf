resource "aws_vpc" "ventura-VPC" {
  cidr_block = var.vpc_cidr_block
  #instance_tenancy = var.instance_tenancy
  tags = {
    Name = "${var.Name}-VPC"
  }
}

# Define a public subnet for the load balancer and bastion host
resource "aws_subnet" "ALB-Subnets" {
  for_each = var.ALB_subnet_configs

  vpc_id                  = aws_vpc.ventura-VPC.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.key # Use the subnet name as the Name tag
  }
}

resource "aws_subnet" "Web-Subnets" {
  for_each = var.web_subnet_configs

  vpc_id            = aws_vpc.ventura-VPC.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key # Use the subnet name as the Name tag
  }
}

resource "aws_subnet" "App-Subnets" {
  for_each = var.app_subnet_configs

  vpc_id            = aws_vpc.ventura-VPC.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key # Use the subnet name as the Name tag
  }
}

resource "aws_subnet" "db-Subnets" {
  for_each = var.db_subnet_configs

  vpc_id            = aws_vpc.ventura-VPC.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key # Use the subnet name as the Name tag
  }
}


resource "aws_internet_gateway" "ventura-IGW" {
  vpc_id = aws_vpc.ventura-VPC.id
  tags = {
    Name = "${var.Name}-IGW"
  }
}

resource "aws_route_table" "ventura-RTb" {
  vpc_id = aws_vpc.ventura-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ventura-IGW.id
  }

  tags = {
    Name = "${var.Name}-RTb"
  }
}

resource "aws_route_table_association" "RTb_for_NAT-ALB" {
  subnet_id      = aws_subnet.ALB-Subnets["Ventura-Prod-NAT-ALB-Subnet-1"].id
  route_table_id = aws_route_table.ventura-RTb.id
}

resource "aws_route_table_association" "RTb_for_ALB" {
  subnet_id      = aws_subnet.ALB-Subnets["Ventura-Prod-ALB-Subnet-2"].id
  route_table_id = aws_route_table.ventura-RTb.id
}