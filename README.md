# Serverless Application Configration With AWS AppConfig Demo 

## Architecture Diagram
![Architecture Diagram](./assets/images/appconfig-lambda-demo.svg)
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_demo_lambda"></a> [demo\_lambda](#module\_demo\_lambda) | terraform-aws-modules/lambda/aws | ~> 5.3.0 |
| <a name="module_demo_lambda_layer"></a> [demo\_lambda\_layer](#module\_demo\_lambda\_layer) | terraform-aws-modules/lambda/aws | ~> 5.3.0 |
| <a name="module_s3_bucket_for_appconfig"></a> [s3\_bucket\_for\_appconfig](#module\_s3\_bucket\_for\_appconfig) | terraform-aws-modules/s3-bucket/aws | ~> 3.14.1 |
| <a name="module_s3_bucket_for_codepipeline_artifact"></a> [s3\_bucket\_for\_codepipeline\_artifact](#module\_s3\_bucket\_for\_codepipeline\_artifact) | terraform-aws-modules/s3-bucket/aws | ~> 3.14.1 |
| <a name="module_trigger_lambda"></a> [trigger\_lambda](#module\_trigger\_lambda) | terraform-aws-modules/lambda/aws | ~> 5.3.0 |
| <a name="module_trigger_lambda_layer"></a> [trigger\_lambda\_layer](#module\_trigger\_lambda\_layer) | terraform-aws-modules/lambda/aws | ~> 5.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appconfig_application.lambda_demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_application) | resource |
| [aws_appconfig_configuration_profile.feature_flag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_configuration_profile) | resource |
| [aws_appconfig_configuration_profile.manual_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_configuration_profile) | resource |
| [aws_appconfig_configuration_profile.pipeline_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_configuration_profile) | resource |
| [aws_appconfig_deployment.feature_flag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment) | resource |
| [aws_appconfig_deployment.manual_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment) | resource |
| [aws_appconfig_deployment_strategy.all_at_once](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment_strategy) | resource |
| [aws_appconfig_deployment_strategy.linear_50_percent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment_strategy) | resource |
| [aws_appconfig_environment.lambda_demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_environment) | resource |
| [aws_appconfig_hosted_configuration_version.feature_flag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_hosted_configuration_version) | resource |
| [aws_appconfig_hosted_configuration_version.manual_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_hosted_configuration_version) | resource |
| [aws_cloudwatch_event_rule.config_upload](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.trigger_config_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_codepipeline.pipeline_cicd_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_policy.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.demo_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.trigger_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.trigger_deploy_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.trigger_deploy_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket_notification.config_upload](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_object.lambda_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_string.stack_random_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current_aws_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.codepipeline_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.demo_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trigger_deploy_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trigger_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_events_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_config_application_name"></a> [app\_config\_application\_name](#input\_app\_config\_application\_name) | The name of the application in AppConfig | `string` | `"lambda-demo"` | no |
| <a name="input_app_config_config_name"></a> [app\_config\_config\_name](#input\_app\_config\_config\_name) | The name of the application configuration in AppConfig | `string` | `"lambda-config"` | no |
| <a name="input_app_config_feature_activation_name"></a> [app\_config\_feature\_activation\_name](#input\_app\_config\_feature\_activation\_name) | The name of the application feature activation flag in AppConfig | `string` | `"lambda-feature-activation"` | no |
| <a name="input_envs_config"></a> [envs\_config](#input\_envs\_config) | Environments configuration | <pre>map(object({<br>    env          = string<br>    deployment   = string<br>    architecture = string<br>  }))</pre> | n/a | yes |
| <a name="input_python_runtime"></a> [python\_runtime](#input\_python\_runtime) | The Python runtime environment | `string` | `"python3.9"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where the backend resources will be deployed | `string` | `"eu-west-1"` | no |
| <a name="input_triggered_lambda_function"></a> [triggered\_lambda\_function](#input\_triggered\_lambda\_function) | Then name of the Lambda function environment that will be triggered by the Triggering Lambda function (e.g. test\_pipeline) | `string` | `"test_pipeline"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arns"></a> [lambda\_arns](#output\_lambda\_arns) | n/a |
| <a name="output_lambda_layer_arns"></a> [lambda\_layer\_arns](#output\_lambda\_layer\_arns) | n/a |
| <a name="output_python_runtime"></a> [python\_runtime](#output\_python\_runtime) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_resources_random_prefix"></a> [resources\_random\_prefix](#output\_resources\_random\_prefix) | ######  Main Outputss ################################################################################################ |
<!-- END_TF_DOCS -->