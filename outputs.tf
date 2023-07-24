#######  Main Outputss ################################################################################################
output "resources_random_prefix" {
  value = random_string.stack_random_prefix.result
}

output "region" {
  value = var.region
}

output "python_runtime" {
  value = var.python_runtime
}

output "lambda_arns" {
  value = { for k, v in module.demo_lambda : k => v.lambda_function_arn }
}

output "lambda_layer_arns" {
  value = { for k, v in module.demo_lambda_layer : k => v.lambda_layer_layer_arn }
}
