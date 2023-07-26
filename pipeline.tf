resource "aws_codepipeline" "appconfig_pipeline" {
  name     = "${random_string.stack_random_prefix.result}-lambda-config-deployment"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = module.s3_bucket_for_codepipeline_artifact.s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["source_output"]
      run_order        = 1
      configuration = {
        S3Bucket             = module.s3_bucket_for_appconfig.s3_bucket_id
        S3ObjectKey          = "lambda-config.zip"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Deploy"

    dynamic "action" {
      for_each = local.pipeline_environments
      content {
        name             = "Deploy${action.value}Config"
        category         = "Deploy"
        owner            = "AWS"
        provider         = "AppConfig"
        input_artifacts  = ["source_output"]
        output_artifacts = []
        version          = "1"
        run_order        = 1
        configuration = {
          Application : aws_appconfig_application.lambda_demo.id
          Environment : aws_appconfig_environment.lambda_demo[action.value].environment_id
          ConfigurationProfile : aws_appconfig_configuration_profile.pipeline_config.configuration_profile_id
          DeploymentStrategy : aws_appconfig_deployment_strategy.linear_50_percent.id
          InputArtifactConfigurationPath : "config/${lower(action.value)}.json"
        }
      }
    }
  }
}