#######  Configure the AWS Provider ###################################################################################
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "Project" = "appconfig demo"
    }
  }
}

#######  Supporting Resources #########################################################################################
data "aws_caller_identity" "current_aws_account" {}

resource "random_string" "stack_random_prefix" {
  length  = 8
  special = false
  upper   = false
  lower   = true
}

locals {
  # The list of environments from the envs_config variable
  environments = distinct([for env_config in var.envs_config : env_config.env])
  # The list of environments that must be deployed by the pipeline (deployment_type = "pipeline")
  pipeline_environments = distinct([
    for env_config in var.envs_config : env_config.env if env_config.deployment_type == "pipeline"
  ])
}
