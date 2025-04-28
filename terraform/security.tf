################
# Security Groups
################

# ALB Security Group: allow HTTP from internet
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB - allows HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg" }
}

# Lambda Security Group: no inbound needed (Lambda can't be directly reached),
# but we'll use this SG for Lambda so it can be allowed in RDS SG.
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security group for Lambda - used to allow DB access"
  vpc_id      = aws_vpc.main.id

  # No explicit ingress rules (Lambda is invoked by ALB, not via network).
  # Outbound is open by default (AWS SG default egress is allow all 0.0.0.0/0).
  tags = { Name = "lambda-sg" }
}

# RDS Security Group: allow MySQL from Lambda SG and developer IP
resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "Security group for RDS MySQL, allow access from Lambda and developer IP"
  vpc_id      = aws_vpc.main.id

  # Ingress rule for Lambda (by referencing Lambda's SG)
  ingress {
    description     = "MySQL access from Lambda function"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id] # allow from any resource with lambda_sg
  }
  # Ingress rule for developer IP (if provided)
  ingress {
    description = "MySQL access from developer IP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = length(var.developer_ip) > 0 ? [var.developer_ip] : []
    # If developer_ip is empty, this yields no ingress rule (no external access).
  }

  egress {
    description = "Allow all outbound from DB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "rds-sg" }
}
