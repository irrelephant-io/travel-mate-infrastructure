variable "env_name" {
  description = "Environment name to deploy to: test/prod/dev/demo"
  type        = string
  default     = "dev"
}

variable "env_region" {
  description = "Region to deploy to"
  type        = string
  default     = "eu-north-1"
}

variable "availability_count" {
  description = "How many availability zones to use"
  type        = number
  default     = 2
}

data "aws_availability_zones" "available" {
  state       = "available"
}
