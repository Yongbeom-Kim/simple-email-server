resource "aws_vpc" "main" {
  cidr_block = "11.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "11.0.0.0/24"
  tags = {
    Name = "${var.service_name}-public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "11.0.1.0/24"
  tags = {
    Name = "${var.service_name}-private"
  }
}

## Public Subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    cidr_block = "11.0.0.0/16"
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

## Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "11.0.0.0/16"
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

## Security Groups
# FIXME: This is probably not the best, but it's a start
# Security group for each service, with ingress/egress rules for specific ports for NFS (EC2 --> EFS)
resource "aws_security_group" "allow_all_local" {
  name        = "${var.service_name}-allow-all-local"
  description = "Allow all local traffic within the VPC"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-allow-all-local"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_local" {
    security_group_id = aws_security_group.allow_all_local.id
    cidr_ipv4 = aws_vpc.main.cidr_block
    ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_local" {
    security_group_id = aws_security_group.allow_all_local.id
    cidr_ipv4 = aws_vpc.main.cidr_block
    ip_protocol = "-1"
}

# Allow EC2 instance connect
resource "aws_security_group" "allow_ec2_instance_connect" {
  name        = "${var.service_name}-allow-ec2_instance_connect"
  description = "Allow EC2 instance connect"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-allow-ec2_instance_connect"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ec2_instance_connect" {
    security_group_id = aws_security_group.allow_ec2_instance_connect.id
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr_ipv4 = "18.206.107.24/29"
}

# Allow internet access
resource "aws_security_group" "allow_internet_access" {
  name        = "${var.service_name}-allow-internet-access"
  description = "Allow internet access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-allow-internet-access"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_internet_access_http" {
    security_group_id = aws_security_group.allow_internet_access.id
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_internet_access_https" {
    security_group_id = aws_security_group.allow_internet_access.id
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
}