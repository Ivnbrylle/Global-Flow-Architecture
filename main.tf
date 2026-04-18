# main.tf (Root Folder)

# 1. Primary Region (Northern Virginia)
module "api_primary" {
  source     = "./modules/serverless_api"
  app_region = "us-east-1"
}

# 2. Secondary Region (Oregon)
module "api_secondary" {
  source     = "./modules/serverless_api"
  app_region = "us-west-2"
  
  # This tells the module to use the "west" provider defined in providers.tf
  providers = {
    aws = aws.west 
  }
}