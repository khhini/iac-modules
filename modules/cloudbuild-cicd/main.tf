locals {
  use_github_repo = var.app_repository.repo_type == "GITHUB"
  use_source_repo = var.app_repository.repo_type == "CLOUD_SOURCE_REPOSITORIES"

  cloudbuild_sa_email = var.cloudbuild_service_account.create ? google_service_account.cloudbuidl_sa[0].email : data.google_service_account.cloudbuild_sa[0].email

  gar_repository_id = var.google_artifact_registry.create ? google_artifact_registry_repository.docker_registry[0].id : data.google_artifact_registry_repository.docker_registry[0].id
  gar_base_uri      = "${var.location}-docker.pkg.dev/${var.project_id}/${var.google_artifact_registry.name}/"
}

# Google Artifact Registry form Docker
data "google_artifact_registry_repository" "docker_registry" {
  count = !var.google_artifact_registry.create ? 1 : 0

  location      = coalesce(var.google_artifact_registry.location, var.location)
  project       = coalesce(var.google_artifact_registry.project_id, var.project_id)
  repository_id = var.google_artifact_registry.name
}

resource "google_artifact_registry_repository" "docker_registry" {
  count = var.google_artifact_registry.create ? 1 : 0

  project       = var.project_id
  location      = var.location
  repository_id = var.google_artifact_registry.name
  format        = "DOCKER"
}

# Application Repository
resource "google_cloudbuildv2_repository" "app_repository" {
  count = local.use_github_repo && var.app_repository.create ? 1 : 0

  location          = var.location
  project           = var.project_id
  name              = "${var.labels.app}-${var.labels.service}"
  parent_connection = var.app_repository.connection_id
  remote_uri        = var.app_repository.remote_uri
}

data "google_sourcerepo_repository" "app_repository" {
  count = local.use_source_repo && !var.app_repository.create ? 1 : 0

  name    = var.app_repository.name
  project = var.app_repository.project_id
}

# Cloud Build Service Accounts
data "google_service_account" "cloudbuild_sa" {
  count = !var.cloudbuild_service_account.create ? 1 : 0

  project    = var.project_id
  account_id = var.cloudbuild_service_account.name
}

resource "google_service_account" "cloudbuidl_sa" {
  count = var.cloudbuild_service_account.create ? 1 : 0

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

  dynamic "repository_event_config" {
    for_each = local.use_github_repo ? { repo = var.app_repository } : {}
    content {
      repository = google_cloudbuildv2_repository.app_repository[0].id
      push {
        branch = var.trigger_branch_name
      }
    }
  }

  dynamic "trigger_template" {
    for_each = local.use_source_repo ? { repo = var.app_repository } : {}
    content {
      branch_name = var.trigger_branch_name
      project_id  = data.google_sourcerepo_repository.app_repository[0].project
      repo_name   = data.google_sourcerepo_repository.app_repository[0].name
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
    repository = local.use_github_repo ? google_cloudbuildv2_repository.app_repository[0].id : null
    uri        = local.use_source_repo ? data.google_sourcerepo_repository.app_repository[0].url : null
    revision   = "refs/heads/${var.trigger_branch_name}"
    repo_type  = var.app_repository.repo_type
  }

  source_to_build {
    repository = local.use_github_repo ? google_cloudbuildv2_repository.app_repository[0].id : null
    uri        = local.use_source_repo ? data.google_sourcerepo_repository.app_repository[0].url : null
    ref        = "refs/heads/${var.trigger_branch_name}"
    repo_type  = var.app_repository.repo_type
  }
}
