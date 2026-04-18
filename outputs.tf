output "primary_region_url" {
  value = module.api_primary.api_endpoint
}

output "secondary_region_url" {
  value = module.api_secondary.api_endpoint
}