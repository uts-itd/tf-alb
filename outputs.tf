output "target_group_arn" {
  value = aws_lb_target_group.alb.arn
}

output "fargate_sg" {
    value = aws_security_group.alb.id
}
