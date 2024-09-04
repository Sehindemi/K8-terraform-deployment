# database/output.tf

output "dbendpoint" {
  value = aws_db_instance.demi_db.endpoint
}