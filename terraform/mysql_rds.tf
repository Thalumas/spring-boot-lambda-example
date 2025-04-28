########################
# RDS MySQL Database Setup
########################

# Database Subnet Group: which subnets RDS can use (we'll use private subnets for isolation)
resource "aws_db_subnet_group" "rds_subnets" {
  name        = "rds-subnet-group"
  description = "Subnet group for RDS"
  subnet_ids  = [for subnet in aws_subnet.private[*] : subnet.id]
  tags        = { Name = "rds-subnet-group" }
}

resource "random_password" "db" {
  length  = 16
  special = false
}
# MySQL RDS Instance
resource "aws_db_instance" "mysql" {
  identifier             = "java21-lambda-db"
  engine                 = "mysql"
  engine_version         = "8.0"         # MySQL 8.x
  instance_class         = "db.t3.micro" # cheapest instance type (MySQL eligible)
  allocated_storage      = 20            # 20 GB storage (minimum for MySQL)
  storage_type           = "gp2"         # General Purpose SSD (gp2)
  multi_az               = false         # single AZ (cheapest option, no high availability)
  publicly_accessible    = true          # allow a public IP for this DB (controlled by SG)
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password != "" ? var.db_password : random_password.db.result

  skip_final_snapshot = true # for easy teardown: skip snapshot on destroy
  tags                = { Name = "MyAppDatabase" }
}
