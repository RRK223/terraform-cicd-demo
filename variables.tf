# variables.tf - All variable declarations go here

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Optional: Add more variables as needed
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "myapp"
}
