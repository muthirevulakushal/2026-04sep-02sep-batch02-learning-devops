resource "aws_lb" "mainalb" {
  name               = "mainalb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.zoneAPublicSubnet.id, aws_subnet.zoneBPublicSubnet.id]
  security_groups    = [aws_security_group.mainsg.id]

  tags = {
    Name = "mainalb"
  }
}

resource "aws_lb_target_group" "mainalbtargetgroup" {
  name     = "mainalbtargetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "listnerforport80" {
  load_balancer_arn = aws_lb.mainalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mainalbtargetgroup.arn
  }
}
