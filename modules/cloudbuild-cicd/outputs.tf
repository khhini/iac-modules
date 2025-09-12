output "cloudbuild_service_account" {
  value       = local.cloudbuild_sa_email
  description = "Cloud Build Service Accounts"
}

output "google_artifact_registry_base_uri" {
  value       = local.gar_base_uri
  description = "Google Artifact Registry base uri"
}

output "ci_pipeline_trigger_id" {
  value = google_cloudbuild_trigger.ci_pipeline_trigger.trigger_id
}

output "cd_pipeline_trigger_id" {
  value = google_cloudbuild_trigger.cd_pipeline_trigger.trigger_id
}
