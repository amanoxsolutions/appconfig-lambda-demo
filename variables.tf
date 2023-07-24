####### General variables #############################################################################################
variable "region" {
  description = "The AWS region where the backend resources will be deployed"
  type        = string
  default     = "eu-west-1"
}

####### Variables to Generate Lambda Layers ###########################################################################
variable "python_runtime" {
  description = "The Python runtime environment"
  type        = string
  default     = "python3.9"
}

variable "envs_config" {
  description = "Environments configuration"
  type = map(object({
    env          = string
    deployment   = string
    architecture = string
  }))
}

variable "app_config_application_name" {
  description = "The name of the application in AppConfig"
  type        = string
  default     = "lambda-demo"
}

variable "app_config_config_name" {
  description = "The name of the application configuration in AppConfig"
  type        = string
  default     = "lambda-config"
}

variable "app_config_feature_activation_name" {
  description = "The name of the application feature activation flag in AppConfig"
  type        = string
  default     = "lambda-feature-activation"
}

variable "triggered_lambda_function" {
  description = "Then name of the Lambda function environment that will be triggered by the Triggering Lambda function (e.g. test_pipeline)"
  type        = string
  default     = "test_pipeline"
}