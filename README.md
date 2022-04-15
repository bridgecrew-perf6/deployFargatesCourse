# Deploying Fargate Tasks
    Learning how to write the infrastructure and automate deployment (Basics)

# Technologies Used:
- terraform
- docker
- aws

# Useful Terraform Commands 
- terraform init -backend-config="confvalues.config"
- terraform plan -var-file="infrastructure.tfvars"
- terraform apply -var-file="infrastructure.tfvars"
- terraform destroy -var-file="infrastructure.tfvars"

# Running Different Stages
- sh deploy.sh build
- sh deploy.sh dockerize
- sh deploy.sh deploy
- sh deploy.sh destroy

