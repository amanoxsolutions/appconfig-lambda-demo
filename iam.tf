#######  Lambda IAM policy #############################################################################################
data "aws_iam_policy_document" "demo_lambda" {
  statement {
    sid = "AllowPutCloudWatchMetricsAngLogs"
    actions = [
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AppConfig"
    actions = [
      "appconfig:GetLatestConfiguration",
      "appconfig:StartConfigurationSession",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "demo_lambda" {
  name   = "${random_string.stack_random_prefix.result}-demo-lambda-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.demo_lambda.json
}

data "aws_iam_policy_document" "trigger_lambda" {
  statement {
    sid = "AllowPutCloudWatchMetricsAngLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AppConfig"
    actions = [
      "lambda:InvokeFunction"
    ]
    effect    = "Allow"
    resources = [for k, v in module.demo_lambda : v.lambda_function_arn]
  }
}

resource "aws_iam_policy" "trigger_lambda" {
  name   = "${random_string.stack_random_prefix.result}-trigger-lambda-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.trigger_lambda.json
}

#######  Code Pipeline IAM policy ######################################################################################
data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    sid = "AllowCodeDeploy"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AllowAccessToS3Bucket"
    actions = [
      "s3:ListBucket",
      "s3:Get*",
      "s3:PutObject*"
    ]
    effect = "Allow"
    resources = [
      module.s3_bucket_for_appconfig.s3_bucket_arn,
      "${module.s3_bucket_for_appconfig.s3_bucket_arn}/*",
      module.s3_bucket_for_codepipeline_artifact.s3_bucket_arn,
      "${module.s3_bucket_for_codepipeline_artifact.s3_bucket_arn}/*"
    ]
  }

  statement {
    sid = "AllowAppConfigDeployments"
    actions = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    sid     = "codepipelineAssumeRole"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "codepipeline_policy" {
  name   = "${random_string.stack_random_prefix.result}-appconfig-codepipeline-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${random_string.stack_random_prefix.result}-appconfig-codepipeline-role"
  description        = "IAM Role for the CodePipeline to deploy AppConfig Configuration"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.id
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

#######  IAM for CodePipeline trigger by EventBridge ##################################################################
data "aws_iam_policy_document" "trust_events_service" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "trigger_deploy_pipeline" {
  name = "${random_string.stack_random_prefix.result}-pipeline-trigger-role"
  assume_role_policy = data.aws_iam_policy_document.trust_events_service.json
}

data "aws_iam_policy_document" "trigger_deploy_pipeline" {
  statement {
    sid       = "AllowStartPipelineExecution"
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = [
      aws_codepipeline.appconfig_pipeline.arn
    ]
  }
}

resource "aws_iam_role_policy" "trigger_deploy_pipeline" {
  name   = "${random_string.stack_random_prefix.result}-pipeline-trigger-policy"
  role   = aws_iam_role.trigger_deploy_pipeline.id
  policy = data.aws_iam_policy_document.trigger_deploy_pipeline.json
}