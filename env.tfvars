envs_config = {
  prod_manual = {
    env             = "Prod"
    deployment_type = "manual"
    architecture    = "x86_64"
  },
  test_pipeline = {
    env             = "Test"
    deployment_type = "pipeline"
    architecture    = "arm64"
  }
}         