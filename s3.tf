module "s3_bucket_for_appconfig" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.14.1"

  bucket = "${random_string.stack_random_prefix.result}-codepipeline-appconfig-lambda-test"
  acl    = "private"

  versioning = {
    enabled = true
  }

  force_destroy = true
}

module "s3_bucket_for_codepipeline_artifact" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.14.1"

  bucket = "${random_string.stack_random_prefix.result}-codepipeline-appconfig-artifactstore"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  force_destroy = true
}

# Upload the local lambda-config.zip file to the AppConfig bucket
resource "aws_s3_object" "lambda_config" {
  bucket = module.s3_bucket_for_appconfig.s3_bucket_id
  key    = "lambda-config.zip"
  source = "./assets/lambda-config.zip"
}