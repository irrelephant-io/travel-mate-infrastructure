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

variable "server_instance_count" {
  description = "How many instances of backend docker image to run"
  type        = number
  default     = 1
}

variable "client_instance_count" {
  description = "How many instance of the front end docker image to run"
  type        = number
  default     = 1
}

variable "ssl_cert_arn" {
  description = "ARN of the SSL certificate within ACM. For now has to be added manually"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the PEM key to access the instances"
  type        = string
}

data "aws_availability_zones" "available" {
  state       = "available"
}

data "template_file" "server_task_defn" {
  template = "${file("${path.module}/server_defn.json.tpl")}"
  vars = {
    repo_url = aws_ecr_repository.travel_mate_server.repository_url
  }
}

data "template_file" "client_task_defn" {
  template = "${file("${path.module}/client_defn.json.tpl")}"
  vars = {
    repo_url = aws_ecr_repository.travel_mate_client.repository_url
    api_url  = "http://travelmate.irrelephant.io"
  }
}

output "lb_address" {
  value = aws_lb.default.dns_name
}

output "server_ecr_url" {
  value = aws_ecr_repository.travel_mate_server.repository_url
}


output "client_ecr_url" {
  value = aws_ecr_repository.travel_mate_client.repository_url
}
