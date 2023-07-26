# There is an AWS provided Terraform module for AppConfig but it currently supports the creation
# of a single deployment, feature configuration.
# I use it here only to create the application.
#module "appconfig" {
#  source  = "terraform-aws-modules/appconfig/aws"
#  version = "~> 1.1.3"
#
#  name        = var.app_config_application_name
#  description = "AppConfig hosted configuration"
#
#  # environments
#  environments = {
#    for env in local.environments : env => {
#      name        = env
#      description = "${var.app_config_application_name} ${env} environment"
#    }
#  }
#
#  # hosted config version
#  use_hosted_configuration           = true
#  config_profile_name = var.app_config_feature_activation_name
#  hosted_config_version_description = "Example Feature Flag Configuration Version"
#  hosted_config_version_content_type = "application/json"
#  hosted_config_version_content = jsonencode({
#    flags : {
#      matrix_decomposition : {
#        name : "Matrix decomposition",
#      },
#    },
#    values : {
#      matrix_decomposition : {
#        enabled : "false",
#      }
#    },
#    version : "1"
#  })
# }
#######  Create AppConfig application ##################################################################################
resource "aws_appconfig_application" "lambda_demo" {
  name        = var.app_config_application_name
  description = "AppConfig configuration for Lambda demo"
}

#######  Create AppConfig Environments #################################################################################
resource "aws_appconfig_environment" "lambda_demo" {
  for_each = toset(local.environments)

  name           = each.value
  description    = "${var.app_config_application_name} ${each.value} environment"
  application_id = aws_appconfig_application.lambda_demo.id
}

#######  Create deployment strategies ##################################################################################
resource "aws_appconfig_deployment_strategy" "all_at_once" {
  name                           = "Demo.AllAtOnce"
  description                    = "Example Deployment Strategy deploying features all at once"
  deployment_duration_in_minutes = 0
  final_bake_time_in_minutes     = 1
  growth_factor                  = 100
  growth_type                    = "LINEAR"
  replicate_to                   = "NONE"
}

resource "aws_appconfig_deployment_strategy" "linear_50_percent" {
  name                           = "Demo.Linear50PercentEveryMinute"
  description                    = "Example Deployment Strategy deploying features all at once"
  deployment_duration_in_minutes = 2
  final_bake_time_in_minutes     = 1
  growth_factor                  = 50
  growth_type                    = "LINEAR"
  replicate_to                   = "NONE"
}

#######  Add extra configurations ######################################################################################
# Creates an AppConfig Feature Flag
resource "aws_appconfig_configuration_profile" "feature_flag" {
  application_id = aws_appconfig_application.lambda_demo.id
  description    = "Example Feature Flag Configuration"
  name           = var.app_config_feature_activation_name
  location_uri   = "hosted"
  type           = "AWS.AppConfig.FeatureFlags"
}

resource "aws_appconfig_hosted_configuration_version" "feature_flag" {
  application_id           = aws_appconfig_application.lambda_demo.id
  configuration_profile_id = aws_appconfig_configuration_profile.feature_flag.configuration_profile_id
  description              = "Example Freeform Hosted Configuration Version"
  content_type             = "application/json"

  content = jsonencode({
    flags : {
      matrix_decomposition : {
        name : "Matrix decomposition",
      },
    },
    values : {
      matrix_decomposition : {
        enabled : "false",
      }
    },
    version : "1"
  })
}

# Creates an AppConfig Hosted Configuration Profile and an initial version
resource "aws_appconfig_configuration_profile" "manual_config" {
  application_id = aws_appconfig_application.lambda_demo.id
  description    = "Example of AppConfig Hosted Configuration Profile"
  name           = "${var.app_config_config_name}-manual"
  location_uri   = "hosted"

  validator {
    type = "JSON_SCHEMA"
    content = jsonencode({
      "$schema" = "http://json-schema.org/draft-04/schema#",
      type      = "object",
      properties = {
        matrix_size = {
          type = "integer"
        }
      },
      additionalProperties = false,
      required             = ["matrix_size"]
    })
  }
}

resource "aws_appconfig_hosted_configuration_version" "manual_config" {
  application_id           = aws_appconfig_application.lambda_demo.id
  configuration_profile_id = aws_appconfig_configuration_profile.manual_config.configuration_profile_id
  description              = "Example Freeform Hosted Configuration Version"
  content_type             = "application/json"

  content = jsonencode({
    matrix_size = 100
  })
}

# Creates a Configuration Profile with CodePipeline as the source
# (we don't create a version for this one since it will be coming from CodePipeline)
resource "aws_appconfig_configuration_profile" "pipeline_config" {
  application_id = aws_appconfig_application.lambda_demo.id
  description    = "Example of AppConfig Provisioned through CodePipeline"
  name           = "${var.app_config_config_name}-pipeline"
  location_uri   = "codepipeline://${var.app_config_config_name}-pipeline"

  validator {
    type = "JSON_SCHEMA"
    content = jsonencode({
      "$schema" = "http://json-schema.org/draft-04/schema#",
      type      = "object",
      properties = {
        matrix_size = {
          type = "integer"
        }
      },
      additionalProperties = false,
      required             = ["matrix_size"]
    })
  }
}

#######  Create the initial deployments for the feature flag and the hosted configuration profile ######################
# The configuration profile with CodePipeline as a source will be automatically triggered by CodePipeline
resource "aws_appconfig_deployment" "feature_flag" {
  for_each = toset(local.environments)

  application_id           = aws_appconfig_application.lambda_demo.id
  configuration_profile_id = aws_appconfig_hosted_configuration_version.feature_flag.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.feature_flag.version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.all_at_once.id
  description              = "Initial deployment of the feature flag"
  environment_id           = aws_appconfig_environment.lambda_demo[each.value].environment_id

  lifecycle {
    ignore_changes = [
      configuration_version
    ]
  }
}

resource "aws_appconfig_deployment" "manual_config" {
  for_each = toset(local.environments)

  application_id           = aws_appconfig_application.lambda_demo.id
  configuration_profile_id = aws_appconfig_hosted_configuration_version.manual_config.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.manual_config.version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.all_at_once.id
  description              = "Initial deployment of the manual configuration profile"
  environment_id           = aws_appconfig_environment.lambda_demo[each.value].environment_id

  lifecycle {
    ignore_changes = [
      configuration_version
    ]
  }
}
