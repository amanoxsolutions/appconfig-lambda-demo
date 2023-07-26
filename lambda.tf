locals {
  # Define the docker image based on the architecture
  docker_image = {
    x86_64 = "public.ecr.aws/sam/build-${var.python_runtime}:latest"
    arm64  = "public.ecr.aws/sam/build-${var.python_runtime}:latest-arm64"
  }
  app_config_lambda_layer_arn = {
    x86_64 = "arn:aws:lambda:eu-west-1:434848589818:layer:AWS-AppConfig-Extension:108"
    arm64  = "arn:aws:lambda:eu-west-1:434848589818:layer:AWS-AppConfig-Extension-Arm64:46"
  }
  # https://docs.aws.amazon.com/appconfig/latest/userguide/appconfig-integration-lambda-extensions.html
}

#######  Demo Lambda Layer #############################################################################################
module "demo_lambda_layer" {
  for_each = var.envs_config
  source   = "terraform-aws-modules/lambda/aws"
  version  = "~> 5.3.0"

  create_layer             = true
  layer_name               = "${random_string.stack_random_prefix.result}-demo-lambda-layer-${lower(each.value.env)}-${each.value.deployment_type}"
  compatible_runtimes      = [var.python_runtime]
  compatible_architectures = [each.value.architecture]

  source_path = [{
    path           = "./assets/lambdas/demo-function/layer"
    poetry_install = true
    prefix_in_zip  = "python"
  }]

  # Only necessary because we are packaging layers from the same source code
  hash_extra = "extra-hash-for-${lower(each.value.env)}-${each.value.deployment_type}-lambda-layer-to-prevent-conflicts-with-other-builds"

  build_in_docker = true
  docker_image    = local.docker_image[each.value.architecture]
  docker_file     = "./assets/docker/Dockerfile"

  runtime = var.python_runtime
}


#######  Demo Lambda ###################################################################################################
module "demo_lambda" {
  for_each = var.envs_config
  source   = "terraform-aws-modules/lambda/aws"
  version  = "~> 5.3.0"

  function_name = "${random_string.stack_random_prefix.result}-demo-lambda-${lower(each.value.env)}-${each.value.deployment_type}"
  description   = "Lambda function which makes some computation"
  handler       = "main.lambda_handler"
  runtime       = var.python_runtime
  architectures = [each.value.architecture]
  publish       = true

  memory_size = 1024
  timeout     = 900

  layers = [
    local.app_config_lambda_layer_arn[each.value.architecture],
    module.demo_lambda_layer[each.key].lambda_layer_arn
  ]

  source_path = "./assets/lambdas/demo-function/main.py"
  # Only necessary because we are packaging lambda functions from the same source code
  hash_extra = "extra-hash-for-${lower(each.value.env)}-${each.value.deployment_type}-lambda-function-to-prevent-conflicts-with-other-builds"

  environment_variables = {
    ENVIRONMENT                                   = each.value.env
    DEPLOYMENT                                    = each.value.deployment_type
    APPLICATION_NAME                              = var.app_config_application_name
    CONFIG_NAME                                   = var.app_config_config_name
    FEATURE_ACTIVATION_NAME                       = var.app_config_feature_activation_name
    AWS_APPCONFIG_EXTENSION_POLL_INTERVAL_SECONDS = 30
  }

  role_name                         = "${random_string.stack_random_prefix.result}-demo-lambda-${lower(each.value.env)}-${each.value.deployment_type}-role"
  role_description                  = "Execution role for the ${random_string.stack_random_prefix.result}-demo-lambda-${lower(each.value.env)}-${each.value.deployment_type} Lambda function"
  attach_policy                     = true
  policy                            = aws_iam_policy.demo_lambda.arn
  cloudwatch_logs_retention_in_days = 7
}

#######  Trigger Lambda Layer #############################################################################################
module "trigger_lambda_layer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.3.0"

  create_layer             = true
  layer_name               = "${random_string.stack_random_prefix.result}-trigger-lambda-layer"
  compatible_runtimes      = [var.python_runtime]
  compatible_architectures = ["x86_64", "arm64"]

  source_path = [{
    path           = "./assets/lambdas/trigger-function/layer"
    poetry_install = true
    prefix_in_zip  = "python"
  }]

  build_in_docker = true
  docker_image    = local.docker_image["x86_64"]
  docker_file     = "./assets/docker/Dockerfile"

  runtime = var.python_runtime
}


#######  Demo Lambda ###################################################################################################
module "trigger_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.3.0"

  function_name = "${random_string.stack_random_prefix.result}-trigger-lambda"
  description   = "Lambda function which makes some computation"
  handler       = "main.lambda_handler"
  runtime       = var.python_runtime
  architectures = ["x86_64"]
  publish       = true

  memory_size = 1024
  timeout     = 900

  layers = [
    module.trigger_lambda_layer.lambda_layer_arn
  ]

  source_path = "./assets/lambdas/trigger-function/main.py"

  environment_variables = {
    LAMBDA_ARN   = module.demo_lambda[local.pipeline_first_environment].lambda_function_arn
    NB_EXECUTION = 20
  }

  role_name                         = "${random_string.stack_random_prefix.result}-trigger-lambda-role"
  role_description                  = "Execution role for the ${random_string.stack_random_prefix.result}-trigger-lambda Lambda function"
  attach_policy                     = true
  policy                            = aws_iam_policy.trigger_lambda.arn
  cloudwatch_logs_retention_in_days = 7
}
