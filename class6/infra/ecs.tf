resource "aws_security_group" "ecs" {
  name        = "${var.environment}-${var.app_name}-sg"
  vpc_id      = aws_vpc.main.id
  description = "allow inbound access from the ALB only"

  ingress {
    protocol        = "tcp"
    from_port       = 8000
    to_port         = 8000
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# ecs cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.app_name}-cluster"
}
# ecs task definition

# json file
data "template_file" "services" {
  template = file("${path.module}/templates/student-portal.tpl")
  vars     = local.student_portals_services_vars
}

# task definition
resource "aws_ecs_task_definition" "services" {
  family                   = "${var.environment}-${var.app_name}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.student_portal_app_cpu
  memory                   = var.student_portal_app_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.services.rendered

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

# ecs service 
resource "aws_ecs_service" "flask_app_service" {
  name                       = "${var.environment}-${var.app_name}-service"
  cluster                    = aws_ecs_cluster.main.id
  task_definition            = aws_ecs_task_definition.services.arn
  desired_count              = var.desired_container_count
  deployment_maximum_percent = 250
  launch_type                = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = var.app_name
    container_port   = 8000
  }

  tags = {
    Environment = var.environment
    Application = "flask-app"
  }
}