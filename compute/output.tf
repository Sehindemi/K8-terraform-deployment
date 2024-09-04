#### - compute/output.tf

output "instance" {
  value     = aws_instance.mtc_node[*]
  sensitive = false
}

output "tg_port" {
  value = aws_lb_target_group_attachment.mtc_tg_attach[0].port
}