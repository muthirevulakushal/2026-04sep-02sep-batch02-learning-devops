resource "aws_subnet" "zoneAPublicSubnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = var.zoneA

  tags = {
    Name = "zoneAPublicSubnet"
  }
}

resource "aws_subnet" "zoneAPrivateSubnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = var.zoneA

  tags = {
    Name = "zoneAPrivateSubnet"
  }
}

resource "aws_subnet" "zoneBPublicSubnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = var.zoneB

  tags = {
    Name = "zoneBPublicSubnet"
  }
}

resource "aws_subnet" "zoneBPrivateSubnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "192.168.4.0/24"
  availability_zone = var.zoneB

  tags = {
    Name = "zoneBPrivateSubnet"
  }
}
