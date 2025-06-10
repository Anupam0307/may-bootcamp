locals {

  student_portals_services_vars = {
    aws_ecr_repository            = aws_ecr_repository.student_portal_app.repository_url
    tag                           = var.tag
    container_name                = var.container_name
    container_port                = var.container_port
    aws_cloudwatch_log_group_name = "/aws/ecs/${var.environment}-${var.app_name}"
    db_link                       = "postgresql://${aws_db_instance.postgres.username}:${random_password.dbs_random_string.result}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
    environment                   = var.environment
    db_host                       = aws_db_instance.postgres.address
  }

  app_deploy_vars = {
    IMAGE_REPO_NAME        = aws_ecr_repository.student_portal_app.repository_url
    ECS_APP_CONTAINER_NAME = var.container_name
    ECS_TASK_DEFINITION    = "${var.environment}-${var.app_name}"
    ECS_SERVICE            = "${var.environment}-${var.app_name}-service"
    ECS_CLUSTER            = aws_ecs_cluster.main.id
    IMAGE_NAME             = "student-portal-app"
  }
}

resource "aws_secretsmanager_secret" "app_deploy_data" {
  name        = "${var.environment}-${var.app_name}-deploy-data"
  description = "Deployment data for the student portal app"
}

resource "aws_secretsmanager_secret_version" "app_deploy_data_version" {
  secret_id     = aws_secretsmanager_secret.app_deploy_data.id
  secret_string = jsonencode(local.app_deploy_vars)
}



# "postgresql://${aws_db_instance.postgres.username}:${random_password.dbs_random_string.result}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
# 'postgresqql://{userbanme}:{password}@{host}:{port}/{db_name}'