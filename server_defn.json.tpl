[
  {
    "essential": true,
    "memory": 256,
    "name": "travel-mate-server",
    "cpu": 1,
    "image": "${repo_url}:latest",
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