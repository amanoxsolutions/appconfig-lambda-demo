#######  EventBridge Resources to Trigger Pipeline   ##################################################################
resource "aws_s3_bucket_notification" "config_upload" {
  bucket      = module.s3_bucket_for_appconfig.s3_bucket_id
  eventbridge = true
}

resource "aws_cloudwatch_event_rule" "config_upload" {
  name           = "${random_string.stack_random_prefix.result}-lambda-config-upload"
  description    = "Capture S3 put object events on the appconfig S3 bucket to trigger lambda config deployment pipeline"
  event_bus_name = "default"

  event_pattern = jsonencode({
    source        = ["aws.s3"]
    "detail-type" = ["Object Created", "Object Restore Completed"]
    detail = {
      bucket = {
        name = [module.s3_bucket_for_appconfig.s3_bucket_id]
      }
      object = {
        key = ["lambda-config.zip"]
      }
    }
  })

}

resource "aws_cloudwatch_event_target" "trigger_config_deployment" {
  event_bus_name = "default"
  rule           = aws_cloudwatch_event_rule.config_upload.name
  role_arn       = aws_iam_role.trigger_deploy_pipeline.arn
  target_id      = aws_codepipeline.appconfig_pipeline.id
  arn            = aws_codepipeline.appconfig_pipeline.arn
}