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
  trigger_branch_name      = "^main*"

  cloudbuild_service_account = {
    name = "cloudbuild-sa"
  }

  google_artifact_registry = {
    name   = "example"
    create = false
  }

  cloudbuildv2_connection_id = "projects/khhini-devops-2705/locations/asia-east1/connections/khhini"
  app_github_remote_repo     = "https://github.com/khhini/devsecops-template.git"

  labels = {
    app     = "example-app"
    service = "backend"
    env     = "dev"
  }

}
