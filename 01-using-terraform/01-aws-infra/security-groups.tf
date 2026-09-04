# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

# Creates Security Group
resource "aws_security_group" "mainsg" {
  name        = "mainsg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "mainsg"
  }
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
  security_group_id = aws_security_group.mainsg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_443" {
  security_group_id = aws_security_group.mainsg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mainsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
