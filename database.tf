# database.tf (Root Folder)

resource "aws_dynamodb_table" "global_api_table" {
  name             = "GlobalUserTable"
  billing_mode     = "PAY_PER_REQUEST" # Best for Free Tier
  hash_key         = "UserId"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "UserId"
    type = "S"
  }

  # This creates the replica in the second region (Oregon)
  # The "primary" will be in the default provider region (Virginia)
  replica {
    region_name = "us-west-2"
  }
}