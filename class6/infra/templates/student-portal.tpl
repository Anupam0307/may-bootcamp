[
  {
    "name": "${container_name}",
    "image": "${aws_ecr_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-south-1",
        "awslogs-stream-prefix": "${aws_cloudwatch_log_group_name}-service",
        "awslogs-group": "${aws_cloudwatch_log_group_name}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${container_port},
        "protocol": "tcp",
        "name": "flask",
        "appProtocol": "http"
      }
    ],
 
    "environment": [
      {
        "name": "ENV",
        "value": "${environment}"
      },
      {
        "name": "DB_LINK",
        "value": "${db_link}"
      }
    ]
  }
]