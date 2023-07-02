{
    "containerDefinitions": [
        {
            "name": "${CONTAINER_NAME}",
            "image": "<IMAGE1_NAME>",
            "cpu": ${AWS_FARGATE_CPU},
            "memory": ${AWS_FARGATE_MEMORY},
            "portMappings": [
                {
                    "name": "${CONTAINER_NAME}-${CONTAINER_PORT}-tcp",
                    "containerPort": ${CONTAINER_PORT},
                    "hostPort": ${CONTAINER_PORT},
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "spring.datasource.username",
                    "value": "${DATABASE_USERNAME}"
                },
                {
                    "name": "spring.datasource.url",
                    "value": "jdbc:${DATABASE_PROFILE}://${DATABASE_ADDRESS}/${DATABASE_NAME}"
                },
                {
                    "name": "spring.profiles.active",
                    "value": "${DATABASE_PROFILE}"
                },
                {
                    "name": "spring.datasource.password",
                    "value": "${DATABASE_PASSWORD}"
                },
                {
                    "name": "spring.datasource.initialize",
                    "value": "yes"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "${CW_LOG_GROUP}",
                    "awslogs-region": "${AWS_DEFAULT_REGION}",
                    "awslogs-stream-prefix": "${CW_LOG_STREAM}"
                }
            }
        }
    ],
    "family": "${CONTAINER_NAME}",
    "executionRoleArn": "${AWS_EXECUTION_ROLE_ARN}",
    "networkMode": "awsvpc",
    "compatibilities": [
        "EC2",
        "FARGATE"
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "${AWS_FARGATE_CPU}",
    "memory": "${AWS_FARGATE_MEMORY}",
}