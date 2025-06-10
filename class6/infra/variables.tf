
variable "region" {
  description = "The region in which the resources will be created"
  default     = "ap-south-1"
}

variable "zone1" {
  description = "The availability zone 1"
  default     = "ap-south-1a"
}

variable "zone2" {
  description = "The availability zone 2"
  default     = "ap-south-1b"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
}

variable "environment" {
  description = "The environment in which the resources will be created"
  default     = "dev"
}
variable "prefix" {
  description = "The prefix for the resources"
  default     = "bootcamp"
}
variable "app_name" {
  description = "The name of the application"
  default     = "student-portal"
}

variable "db_default_settings" {
  type = any
  default = {
    allocated_storage       = 30
    max_allocated_storage   = 50
    engine_version          = 14.15
    instance_class          = "db.t3.micro"
    backup_retention_period = 2
    db_name                 = "postgres"
    ca_cert_name            = "rds-ca-rsa2048-g1"
    db_admin_username       = "postgres"
  }
}


# application details

variable "app_domain" {
  default = "akhileshmishra.tech"
}
variable "tag" {
  description = "value for the tag"
  default     = "latest"
}
variable "container_name" {
  default = "student-portal"
}
variable "container_port" {
  description = "The port on which the container will listen"
  default     = 8000
}

variable "student_portal_app_cpu" {
  description = "The CPU units for the Flask app"
  default     = 256
}
variable "student_portal_app_memory" {
  description = "The memory in MiB for the Flask app"
  default     = 512
}

variable "desired_container_count" {
  description = "The number of desired containers for the ECS service"
  default     = 2

}

variable "subnet_cidr" {
  type = map(string)

  default = {
    "prvate_1"    = "10.0.1.0/24"
    "prvate_2"    = "10.0.2.0/24"
    "public_1"    = "10.0.3.0/24"
    "public_2"    = "10.0.4.0/24"
    "db_subnet_1" = "10.0.1.0/24"
    "db_subnet_2" = "10.0.1.0/24"
  }

}