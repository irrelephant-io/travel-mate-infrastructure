terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.27"
        }
    }

    required_version = ">= 0.14.9"
}

provider "aws" {
    profile = "default"
    region  = "eu-north-1"
}

resource "aws_instance" "travelmate_cluster_instance_${var.env_name}" {
    instance_type   = "t3.micro"

    # ECS-optimized Amazon Linux 2
    ami             = "ami-0e74361b71c3bbc04"

    tags = {
        Name = "travelmate_${var.env_name}"
    }
}
