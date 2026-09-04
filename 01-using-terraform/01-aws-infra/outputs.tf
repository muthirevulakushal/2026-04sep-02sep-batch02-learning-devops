output "load_balancer_dns" {
  value = aws_lb.mainalb.dns_name
}