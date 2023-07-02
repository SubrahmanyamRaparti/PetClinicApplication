version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION> # https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-ecs-ecr-codedeploy.html#tutorials-ecs-ecr-codedeploy-taskdefinition
        LoadBalancerInfo:
          ContainerName: "${CONTAINER_NAME}"
          ContainerPort: "${CONTAINER_PORT}"
# Optional properties
#         PlatformVersion: "LATEST"
#         NetworkConfiguration:
#           AwsvpcConfiguration:
#             Subnets: ["subnet-1234abcd","subnet-5678abcd"]
#             SecurityGroups: ["sg-12345678"]
#             AssignPublicIp: "ENABLED"
#         CapacityProviderStrategy:
#           - Base: 1
#             CapacityProvider: "FARGATE_SPOT"
#             Weight: 2
#           - Base: 0
#             CapacityProvider: "FARGATE"
#             Weight: 1
# Hooks:
#   - BeforeInstall: "LambdaFunctionToValidateBeforeInstall"
#   - AfterInstall: "LambdaFunctionToValidateAfterInstall"
#   - AfterAllowTestTraffic: "LambdaFunctionToValidateAfterTestTrafficStarts"
#   - BeforeAllowTraffic: "LambdaFunctionToValidateBeforeAllowingProductionTraffic"
#   - AfterAllowTraffic: "LambdaFunctionToValidateAfterAllowingProductionTraffic"