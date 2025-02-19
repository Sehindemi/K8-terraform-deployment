#---  networking/output.tf ----


output "vpc_id" {
  value = aws_vpc.demi_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.mtc_rds_subnet_group.*.name
}

output "db_security_group" {
  value = [aws_security_group.demi_sg["rds"].id]
}

output "public_subnets" {
  value = aws_subnet.demi_public_subnet.*.id
}

output "public_sg" {
  value = aws_security_group.demi_sg["public"].id

}