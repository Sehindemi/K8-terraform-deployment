#---  networking/output.tf ----


output "vpc_id" {
  value = aws_vpc.demi_vpc.id
}