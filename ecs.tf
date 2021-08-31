resource "aws_ecr_repository" "travel_mate_server" {
  name = "travel-mate-server"
}

resource "aws_ecr_repository" "travel_mate_client" {
  name = "travel-mate-client"
}

resource "aws_ecs_cluster" "travel_mate" {
  name = "travel-mate-${var.env_name}"
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type  = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name = "travel-mate-ecs-agent-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "travel-mate-ecs-agent-profile-${var.env_name}"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
  # ECS-optimized Amazon Linux 2
  image_id             = "ami-0e74361b71c3bbc04"

  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.travel_mate_server_task.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=travel-mate-${var.env_name} >> /etc/ecs/ecs.config"
  instance_type        = "t3.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  count                = var.availability_count
  name                 = "travel-mate-asg-${var.env_name}"
  vpc_zone_identifier  = [element(aws_subnet.private.*.id, count.index)]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity     = 2
  min_size             = 1
  max_size             = 10
  health_check_grace_period = 300
  health_check_type    = "EC2"
}

resource "aws_ecs_task_definition" "travel_mate_server" {
  family = "travel-mate-server"
  container_definitions = data.template_file.server_task_defn.rendered
  network_mode = "awsvpc"
}

resource "aws_ecs_task_definition" "travel_mate_client" {
  family = "travel-mate-client"
  container_definitions = data.template_file.client_task_defn.rendered
  network_mode = "awsvpc"
}

resource "aws_ecs_service" "travel_mate_server" {
  name = "travel-mate-server"
  cluster = aws_ecs_cluster.travel_mate.id
  task_definition = aws_ecs_task_definition.travel_mate_server.arn
  desired_count = var.server_instance_count
  launch_type = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.travel_mate_server.id
    container_name = "travel-mate-server"
    container_port = 8080
  }

  network_configuration {
    security_groups = [aws_security_group.travel_mate_server_task.id]
    subnets         = aws_subnet.private.*.id
  }

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener.https
  ]
}

resource "aws_ecs_service" "travel_mate_client" {
  name = "travel-mate-client"
  cluster = aws_ecs_cluster.travel_mate.id
  task_definition = aws_ecs_task_definition.travel_mate_client.arn
  desired_count = var.client_instance_count
  launch_type = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.travel_mate_client.id
    container_name = "travel-mate-client"
    container_port = 8079
  }

  network_configuration {
    security_groups = [aws_security_group.travel_mate_client_task.id]
    subnets         = aws_subnet.private.*.id
  }

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener.https
  ]
}
