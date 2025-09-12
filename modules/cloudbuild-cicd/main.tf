locals {
  create_cloudbuild_sa = var.cloudbuild_service_account.create ? 1 : 0
  data_cloudbuild_sa   = var.cloudbuild_service_account.create ? 0 : 1
  cloudbuild_sa_email  = var.cloudbuild_service_account.create ? google_service_account.cloudbuidl_sa[0].email : data.google_service_account.cloudbuild_sa[0].email


  create_gar        = var.google_artifact_registry.create ? 1 : 0
  data_gar          = var.google_artifact_registry.create ? 0 : 1
  gar_repository_id = var.google_artifact_registry.create ? google_artifact_registry_repository.docker_registry[0].id : data.google_artifact_registry_repository.docker_registry[0].id
  gar_base_uri      = "${var.location}-docker.pkg.dev/${var.project_id}/${var.google_artifact_registry.name}/"
}

# Google Artifact Registry form Docker
data "google_artifact_registry_repository" "docker_registry" {
  count = local.data_gar

  location      = var.location
  project       = var.project_id
  repository_id = var.google_artifact_registry.name
}

resource "google_artifact_registry_repository" "docker_registry" {
  count = local.create_gar

  project       = var.project_id
  location      = var.location
  repository_id = var.google_artifact_registry.name
  format        = "DOCKER"
}

# Application Repository
resource "google_cloudbuildv2_repository" "app_repository" {
  location          = var.location
  project           = var.project_id
  name              = "${var.labels.app}-${var.labels.service}"
  parent_connection = var.cloudbuildv2_connection_id
  remote_uri        = var.app_github_remote_repo
}


# Cloud Build Service Accounts
data "google_service_account" "cloudbuild_sa" {
  count = local.data_cloudbuild_sa

  project    = var.project_id
  account_id = var.cloudbuild_service_account.name
}

resource "google_service_account" "cloudbuidl_sa" {
  count = local.create_cloudbuild_sa

  project      = var.project_id
  account_id   = var.cloudbuild_service_account.name
  display_name = "Cloud Build Service Accounts"
}

# Cloud Build Service Account Permissions 
resource "google_project_iam_member" "cloudbuild_sa_project_iam" {
  for_each = toset(var.cloudbuild_service_account_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${local.cloudbuild_sa_email}"
}

# Cloud BUILD CI Pipeline
resource "google_cloudbuild_trigger" "ci_pipeline_trigger" {
  name            = "${var.labels.app}-${var.labels.service}-ci-${var.labels.env}"
  location        = var.location
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  repository_event_config {
    repository = google_cloudbuildv2_repository.app_repository.id
    push {
      branch = var.trigger_branch_name
    }
  }

  ignored_files = var.ci_pipeline_ignored_files

  filename = var.ci_pipeline_trigger_yaml

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

# Cloud BUILD CD Pipeline
resource "google_cloudbuild_trigger" "cd_pipeline_trigger" {
  name            = "${var.labels.app}-${var.labels.service}-cd-${var.labels.env}"
  location        = var.location
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  git_file_source {
    path       = var.cd_pipeline_trigger_yaml
    repository = google_cloudbuildv2_repository.app_repository.id
    revision   = "refs/heads/${var.trigger_branch_name}"
    repo_type  = "GITHUB"
  }

  source_to_build {
    repository = google_cloudbuildv2_repository.app_repository.id
    ref        = "refs/heads/${var.trigger_branch_name}"
    repo_type  = "GITHUB"
  }
}
