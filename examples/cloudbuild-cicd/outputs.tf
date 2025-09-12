output "cloudbuild_service_account" {
  value = module.cloudbuild_pipeline.cloudbuild_service_account
}

output "google_artifact_registry_base_uri" {
  value = module.cloudbuild_pipeline.google_artifact_registry_base_uri
}

output "ci_pipeline_trigger_id" {
  value = module.cloudbuild_pipeline.ci_pipeline_trigger_id
}

output "cd_pipeline_trigger_id" {
  value = module.cloudbuild_pipeline.cd_pipeline_trigger_id
}
