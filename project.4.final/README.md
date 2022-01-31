# terraform aws pipeline
Creates an AWS code pipeline using HashiCorp Terraform that deploys a Flask App into an AWS ECS cluster with autoscaling configured

```
## Export AWS credentials
```
export AWS_ACCESS_KEY_ID="AXXXXXXX"
export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXXXXX"
export AWS_DEFAULT_REGION="us-east-1"

```
## Configure AWS Codecommit credentials in Git
```
aws configure  # add credentials
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

```
* Initialize Terraform
```
terraform init

```
* Deploy pipeline
```
terraform apply
