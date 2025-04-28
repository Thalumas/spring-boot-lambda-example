#############################
# Application Load Balancer and Target Group
#############################

# ALB resource (internet-facing)
resource "aws_lb" "alb" {
  name                       = "lambda-alb"
  internal                   = false # false = internet-facing
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [for subnet in aws_subnet.public[*] : subnet.id] # place ALB in public subnets
  enable_deletion_protection = false                                            # for easy teardown; in prod consider enabling protection
  tags                       = { Name = "Lambda-ALB" }
}

# Target Group for Lambda
resource "aws_lb_target_group" "lambda_tg" {
  name                               = "lambda-target-group"
  target_type                        = "lambda"
  lambda_multi_value_headers_enabled = true

  tags = {
    Name = "LambdaTargetGroup"
  }
}
resource "aws_lb_target_group_attachment" "lambda_attachment" {
  target_group_arn = aws_lb_target_group.lambda_tg.arn
  target_id        = aws_lambda_function.app_lambda.arn
}
# ALB Listener for HTTP (port 80) -> forwards to Lambda target group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }
}
