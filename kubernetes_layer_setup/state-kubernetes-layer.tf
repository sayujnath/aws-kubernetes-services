
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }


        local = {
            source  = "hashicorp/local"
            version = "2.1.0"
        }

        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0.1"
        }
    }

    backend "s3" {
        bucket = " example-terraform-state-sg"         // MODIFY FOR NEW DEPLOYMENT - new region for bucket. Please create the bucket first.
        key    = MAKE_UNIQUE/terraform-k8s.tfstate   # "example-deployment/terraform-k8s.tfstate"     // !!!!!!!! MODIFY FOR NEW DEPLOYMENT - new key in s3 for new deployment in existing region
        encrypt = true
        region = "ap-southeast-1"                   // MODIFY FOR NEW DEPLOYMENT - new region
        profile = "prod-us-west-2"                       // MODIFY FOR NEW DEPLOYMENT - alternative AWS credentials for different account
        dynamodb_table = " example-terraform-state-sg" // MODIFY FOR NEW DEPLOYMENT - new lock for each deployment 
    }

}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = " example-terraform-state-sg"             // !!!!!!! MODIFY FOR NEW DEPLOYMENT - has to match bucket in infra layer
    key    = SAME_AS_INFRA_STATE_KEY/terraform.tfstate             // ie example-deployment/terraform.tfstate !!!!!!! MODIFY FOR NEW DEPLOYMENT - has to match state key in infra layer
    region = "ap-southeast-1"                       // !!!!!!! MODIFY FOR NEW DEPLOYMENT - has to match region in infra layer
    profile = "prod-us-west-2"
  }
}

// Extract resource outputs from infrastructure layer
# Configure the AWS Provider and region
provider "aws" {
    profile = data.terraform_remote_state.eks.outputs.aws_cli_profile
    region = data.terraform_remote_state.eks.outputs.region

    default_tags {
    tags = data.terraform_remote_state.eks.outputs.default_tags
  }
}



provider "kubernetes" {

    config_path    = "~/.kube/config"
    config_context = data.terraform_remote_state.eks.outputs.context_name
}

provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
        config_context = data.terraform_remote_state.eks.outputs.context_name
    }
}

