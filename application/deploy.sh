#!/bin/sh

SERVICE_NAME="springbootapp"
SERVICE_TAG="latest"
ECR_REPOSITORY_URI="569057232436.dkr.ecr.eu-west-2.amazonaws.com/${SERVICE_NAME}"


if [ "$1" = "build" ]; then
  echo "starting to build spring app..."
  cd appsrc/
  mvn clean install

elif [ "$1" = "dockerize" ]; then
    echo "creating docker image..."
    find ./appsrc/target -type f \( -name "*.jar" -not -name "*sources.jar" \) -exec cp {} $SERVICE_NAME.jar \;
    $(aws ecr get-login --no-include-email --region eu-west-2)
    aws ecr create-repository --repository-name ${SERVICE_NAME:?} || true
    docker build -t ${SERVICE_NAME} .
    docker tag ${SERVICE_NAME}:${SERVICE_TAG} ${ECR_REPOSITORY_URI}:${SERVICE_TAG}
    docker push ${ECR_REPOSITORY_URI}:${SERVICE_TAG}

elif [  "$1" = "plan" ]; then
      terraform init -upgrade -backend-file="application.config"
      terraform plan --var-file="application.tfvars" -var "docker_image_url=${ECR_REPOSITORY_URI}:${SERVICE_TAG}"

elif [  "$1" = "deploy" ]; then
  terraform init -upgrade -backend-file="application.config"
  terraform taint allow-missing aws_ecs_task_definition.spring-app-task
  terraform apply -var-file="application.tfvars" -var "docker_image_url=${ECR_REPOSITORY_URI}:${SERVICE_TAG}" -auto-approve

elif [  "$1" = "destroy" ]; then
        terraform init -upgrade -backend-file="application.config"
        terraform destroy -var-file="application.tfvars" -var "docker_image_url=${ECR_REPOSITORY_URI}:${SERVICE_TAG}" -auto-approve
fi
