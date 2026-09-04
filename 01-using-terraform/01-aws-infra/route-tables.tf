resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "gw"
  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  #route {
  #ipv6_cidr_block        = "::/0"
  #egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  #}

  tags = {
    Name = "PublicRouteTable"
  }
}


resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "PrivateRouteTable"
  }
}


resource "aws_route_table_association" "zoneAPublicSubnetAssociation" {
  subnet_id      = aws_subnet.zoneAPublicSubnet.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "zoneAPrivateSubnetAssociation" {
  subnet_id      = aws_subnet.zoneAPrivateSubnet.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}


resource "aws_route_table_association" "zoneBPublicSubnetAssociation" {
  subnet_id      = aws_subnet.zoneBPublicSubnet.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "zoneBPrivateSubnetAssociation" {
  subnet_id      = aws_subnet.zoneBPrivateSubnet.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}
