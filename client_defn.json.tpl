[
  {
    "essential": true,
    "memory": 512,
    "name": "travel-mate-client",
    "cpu": 1024,
    "image": "${repo_url}:latest",
    "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/travel-mate-client",
          "awslogs-region": "eu-north-1",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
        {
          "hostPort": 8079,
          "protocol": "tcp",
          "containerPort": 8079
        }
    ],
    "environment": [
        {
          "name": "API_URI",
          "value": "${api_url}"
        },
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "SRV_HOST",
          "value": "0.0.0.0"
        },
        {
          "name": "SRV_PORT",
          "value": "8079"
        }
    ]
  }
]