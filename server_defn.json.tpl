[
  {
    "essential": true,
    "memory": 444,
    "name": "travel-mate-server",
    "cpu": 1024,
    "image": "${repo_url}:latest",
    "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/travel-mate-server",
          "awslogs-region": "eu-north-1",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
        {
          "hostPort": 8080,
          "protocol": "tcp",
          "containerPort": 8080
        }
    ],
    "environment": [
        {
          "name": "RUST_LOG",
          "value": "info"
        },
        {
          "name": "SRV_HOST",
          "value": "0.0.0.0"
        },
        {
          "name": "SRV_PORT",
          "value": "8080"
        }
      ]
  }
]