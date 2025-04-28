# terraform.tfvars

# The AWS region is set in provider, but you could also specify it via environment or here if needed.
# region        = "eu-west-2"

vpc_cidr             = "10.10.0.0/16" # custom VPC range (optional change)
public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
private_subnet_cidrs = ["10.10.2.0/24", "10.10.3.0/24"]

allow_lambda_internet_access = false           # keep false to avoid NAT costs (true if Lambda needs internet)
developer_ip                 = "" # replace with your IP for DB access, or "" for none

db_name     = "gamedb"
db_username = "admin"
db_password = "31031949J!ll" # choose a strong password or leave empty to generate one

lambda_package_path  = "demo-java-lambda-1.0-lambda-package.zip" # path to your Lambda deployment package
handler_class_method = "uk.co.thalumas.lambda.LambdaHandler::handleRequest"
lambda_memory_mb     = 256 # adjust memory (MB) as needed
lambda_timeout_s     = 15  # adjust timeout (seconds) as needed
