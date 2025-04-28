################
# Outputs
################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (use this to call the Lambda via HTTP)"
  value       = aws_lb.alb.dns_name
}

output "db_endpoint" {
  description = "Endpoint (host) of the RDS MySQL database"
  value       = aws_db_instance.mysql.endpoint
}

output "db_port" {
  description = "Port of the RDS MySQL database (should be 3306)"
  value       = aws_db_instance.mysql.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.mysql.db_name
}

output "db_username" {
  description = "Master username for the database"
  value       = var.db_username
}

output "db_password" {
  description = "Master password for the database (if generated, capture this!)"
  value       = aws_db_instance.mysql.password
  sensitive   = true # marks the output as sensitive so Terraform masks it in logs
}
