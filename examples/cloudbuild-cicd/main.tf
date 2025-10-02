module "cloudbuild_pipeline" {
  source = "../../modules/cloudbuild-cicd"

  project_id = var.project_id
  location   = var.region

  ci_pipeline_trigger_yaml = "./deployment/build/cloudbuild.yaml"
  ci_pipeline_ignored_files = [
    "**/build/cloudbuild.cd.yaml",
    "**/scripts/*",
    "**/*.tf"
  ]

  cd_pipeline_trigger_yaml = "./deployment/build/cloudbuild.cd.yaml"
  trigger_branch_name      = var.trigger_branch_name

  cloudbuild_service_account = {
    name = "cloudbuild-sa"
  }

  google_artifact_registry = {
    name   = "example"
    create = false
  }

  app_repository = {
    connection_id = "projects/khhini-devops-2705/locations/asia-east1/connections/khhini",
    remote_uri    = "https://github.com/khhini/devsecops-template.git"
    repo_type     = "GITHUB"
  }

  labels = {
    app     = "example-app"
    service = "backend"
    env     = var.app_env
  }

}
