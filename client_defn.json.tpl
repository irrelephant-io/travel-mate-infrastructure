[
  {
    "essential": true,
    "memory": 512,
    "name": "travel-mate-client",
    "cpu": 1,
    "image": "${repo_url}:latest",
    "portMappings": [
        {
          "hostPort": 8079,
          "protocol": "tcp",
          "containerPort": 8079
        }
    ],
    "environment": [
        {
          "name": "API_URL",
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