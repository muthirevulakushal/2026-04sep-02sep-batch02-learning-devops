# Launch Instances based on Template configured
resource "aws_launch_template" "main_launch_template" {
  name          = "main_launch_template"
  image_id      = var.ami_map[var.env]
  instance_type = var.instance_type
  key_name      = var.key_name

  # vpc_security_group_ids = [aws_security_group.mainsg.id]

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    #subnet_id      = [aws_subnet.zoneAPublicSubnet.id, aws_subnet.zoneBPublicSubnet.id]
    subnet_id       = aws_subnet.zoneAPublicSubnet.id
    security_groups = [aws_security_group.mainsg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "main_launch_template"
    }
  }

  user_data = filebase64("${path.module}/install.sh")
}


# Launch Instances based on Template configured
resource "aws_launch_template" "local_launch_template" {
  name          = "local_launch_template"
  image_id      = var.ami_map[var.env]
  instance_type = local.instance_type
  key_name      = var.key_name

  # vpc_security_group_ids = [aws_security_group.mainsg.id]

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    #subnet_id      = [aws_subnet.zoneAPublicSubnet.id, aws_subnet.zoneBPublicSubnet.id]
    subnet_id       = aws_subnet.zoneAPublicSubnet.id
    security_groups = [aws_security_group.mainsg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "main_launch_template"
    }
  }

  user_data = filebase64("${path.module}/install.sh")
}

locals {
  instance_type = var.env == "prod" ? "a1.medium" :"a1.large"
}