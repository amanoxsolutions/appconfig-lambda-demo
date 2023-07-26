#######  Main Outputs ################################################################################################
output "lambda_arns" {
  description = "The ARNs of the Lambda functions"
  value       = { for k, v in module.demo_lambda : k => v.lambda_function_arn }
}

output "lambda_layer_arns" {
  description = "The ARNs of the Lambda layers"
  value       = { for k, v in module.demo_lambda_layer : k => v.lambda_layer_layer_arn }
}

output "appconfig_arn" {
  description = "The ARN of the AppConfig application"
  value       = aws_appconfig_application.lambda_demo.arn
}

output "appconfig_id" {
  description = "The ID of the AppConfig application"
  value       = aws_appconfig_application.lambda_demo.id
}

output "codepipeline_arn" {
  description = "The ARN of the CodePipeline"
  value       = aws_codepipeline.appconfig_pipeline.arn
}
