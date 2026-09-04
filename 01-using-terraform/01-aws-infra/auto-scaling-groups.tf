# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#with-latest-version-of-launch-template

# Create Auto Scaling Group with Launch Template
resource "aws_autoscaling_group" "mainasg" {
  name                = "mainasg"
  vpc_zone_identifier = [aws_subnet.zoneAPublicSubnet.id, aws_subnet.zoneBPublicSubnet.id]
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.main_launch_template.id
    version = "$Latest"
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "mainasgattachmentwithalb" {
  autoscaling_group_name = aws_autoscaling_group.mainasg.id
  lb_target_group_arn =    aws_lb_target_group.mainalbtargetgroup.arn
}