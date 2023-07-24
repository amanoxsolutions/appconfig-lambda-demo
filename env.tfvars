envs_config = {
  prod_manual = {
    env          = "Prod"
    deployment   = "manual"
    architecture = "x86_64"
  },
  prod_pipeline = {
    env          = "Prod"
    deployment   = "pipeline"
    architecture = "x86_64"
  },
  test_manual = {
    env          = "Test"
    deployment   = "manual"
    architecture = "arm64"
  },
  test_pipeline = {
    env          = "Test"
    deployment   = "pipeline"
    architecture = "arm64"
  }
}         