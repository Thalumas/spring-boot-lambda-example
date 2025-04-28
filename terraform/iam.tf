###########################
# Lambda Function and IAM Role
###########################

# IAM role for Lambda execution, with basic Lambda and VPC access permissions
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Action" : "sts:AssumeRole",
      "Principal" : { "Service" : "lambda.amazonaws.com" },
      "Effect" : "Allow"
    }]
  })
  tags = { Name = "lambda-exec-role" }
}

# Attach AWS managed policies for basic Lambda execution and VPC access
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

# Lambda Function definition
resource "aws_lambda_function" "app_lambda" {
  function_name = "Java21LambdaFunction"
  description   = "Java 21 Lambda behind ALB example"
  runtime       = "java21" # Java 21 runtime (if not available, use latest or provide custom image)
  handler       = var.handler_class_method
  memory_size   = var.lambda_memory_mb
  timeout       = var.lambda_timeout_s

  filename         = var.lambda_package_path                   # path to your ZIP package
  source_code_hash = filebase64sha256(var.lambda_package_path) # ensures Terraform updates function if code changes

  role = aws_iam_role.lambda_exec.arn

  # Connect Lambda to the VPC (so it can reach RDS)
  vpc_config {
    subnet_ids         = [for subnet in aws_subnet.private[*] : subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  # Environment variables for DB connection
  environment {
    variables = {
      DB_HOST     = aws_db_instance.mysql.endpoint # RDS endpoint address
      DB_PORT     = aws_db_instance.mysql.port     # RDS port (3306)
      DB_NAME     = var.db_name
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password != "" ? var.db_password : random_password.db.result
    }
  }

  tags = { Name = "Java21LambdaFunction" }
}

# Allow the ALB to invoke the Lambda function
resource "aws_lambda_permission" "alb_invoke" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app_lambda.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  # Restrict permission to our Load Balancer's Target Group
  source_arn = aws_lb_target_group.lambda_tg.arn
}
