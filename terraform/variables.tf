#############################
# Input Variables Definitions
#############################

# VPC network settings
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"] # two public subnets in two AZs
}
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"] # two private subnets in two AZs
}

# Toggle for Lambda's internet access (via NAT Gateway)
variable "allow_lambda_internet_access" {
  description = "Set true to give Lambda internet access via a NAT Gateway"
  type        = bool
  default     = false # default is VPC-internal only (no NAT Gateway)
}

# Developer's IP for DB access (in CIDR format, e.g., 'X.X.X.X/32')
variable "developer_ip" {
  description = "Public IP (CIDR) allowed to access the database (for setup)"
  type        = string
  default     = "82.32.11.9/32" # e.g., "203.0.113.4/32"; empty means no external DB access
}

# RDS database settings
variable "db_name" {
  description = "Database name for RDS MySQL"
  type        = string
  default     = "appdb"
}
variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "admin"
}
variable "db_password" {
  description = "Master password for RDS (if not set, a random password will be used)"
  type        = string
  default     = "" # strongly recommended to set in .tfvars or let random generator create one
}

# Lambda function settings
variable "lambda_package_path" {
  description = "Path to the Lambda deployment package (ZIP file)"
  type        = string
  default     = "function.zip" # assume the ZIP is in the current directory
}
variable "lambda_memory_mb" {
  description = "Memory size for Lambda (MB)"
  type        = number
  default     = 512 # example memory, adjust as needed
}
variable "lambda_timeout_s" {
  description = "Timeout for Lambda function (seconds)"
  type        = number
  default     = 30 # example timeout, adjust as needed
}
variable "handler_class_method" {
  description = "Class and Method used to handle Lambda call."
  type        = string
  default     = "com.example.lambda.Handler::handle"
}
