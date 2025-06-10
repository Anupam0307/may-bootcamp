# .tfvars
vpc_cidr = "10.0.0.0/16"
app_name = "student-portal"


subnet_cidr = {
  "private_1"   = "10.0.1.0/24"
  "private_2"   = "10.0.2.0/24"
  "public_1"    = "10.0.3.0/24"
  "public_2"    = "10.0.4.0/24"
  "db_subnet_1" = "10.0.5.0/24"
  "db_subnet_2" = "10.0.6.0/24"
}