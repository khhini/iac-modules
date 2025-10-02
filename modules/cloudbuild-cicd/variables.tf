
variable "project_id" {
  type        = string
  description = "Project ID for CICD Pipeline Project"
}

variable "location" {
  type        = string
  description = "Region for CICD Pipeline"
}

variable "cloudbuild_service_account" {
  type = object({
    name   = string
    create = optional(bool, true)
  })
  description = <<-EOT
    Parameters that will be used to define Service Account for Cloud Build.
    If create fields set to false. terraform will get data of exisiting resources.
    Example:
      google_artifact_registry = {
        name = "cloudbuild-sa"
        create = true
      }
  EOT
}

variable "ci_pipeline_trigger_yaml" {
  type        = string
  description = "Name of CI pipeline cloudbuild yaml file"
}
variable "ci_pipeline_ignored_files" {
  type        = list(string)
  description = "List of file that ingored from triggering pipeline"
  default     = []
}

variable "cd_pipeline_trigger_yaml" {
  type        = string
  description = "Name of CD pipeline cloudbuild yaml file"
}

variable "trigger_branch_name" {
  type        = string
  description = "A regular expression to match one or more branches for the build trigger."
}

variable "app_repository" {
  type = object({
    connection_id = optional(string, null)
    remote_uri    = optional(string, null)
    repo_type     = optional(string, null)
    project_id    = optional(string, null)
    name          = optional(string, null)
    create        = optional(bool, true)
  })
  description = <<-EOT
    Paramters that will be used to define Application Repository.
    If create fields set to false. terraform will get data of existing resources.
    Example: 
      # USING GITHUB REPOSITORY
      app_repository = {
        connection_id     = ""  
        remote_uri = "https://github.com/khhini/example"
        repo_type         = "GITHUB"
        create            = false
      }
      # USING CLOUD_SOURCE_REPOSITORIES
      app_repository = {
        name              = "app_repository"
        project_id        = "source-repo-project-id"
        repo_type         = "CLOUD_SOURCE_REPOSITORIES"
        create            = false
      }
  EOT

  validation {
    condition     = contains(["GITHUB", "CLOUD_SOURCE_REPOSITORIES"], var.app_repository.repo_type)
    error_message = "Invalid app_repository.repo_type. Must be one of: 'GITHUB', or 'CLOUD_SOURCE_REPOSITORIES'."
  }
}

variable "google_artifact_registry" {
  type = object({
    name       = string
    project_id = optional(string, null)
    location   = optional(string, null)
    create     = optional(bool, true)
  })
  description = <<-EOT
    Parameters that will be used to define Google Artifact Registry.
    If create fields set to false. terraform will get data of exisiting resources.
    Example:
      google_artifact_registry = {
        name = "example"
        create = true
      }
  EOT
}


variable "cloudbuild_service_account_roles" {
  type        = list(string)
  description = "IAM roles given to the Cloud Build service account to enable security scanning operations"
  default = [
    "roles/artifactregistry.admin",
    "roles/binaryauthorization.attestorsVerifier",
    "roles/cloudbuild.builds.builder",
    "roles/clouddeploy.developer",
    "roles/clouddeploy.releaser",
    "roles/cloudkms.cryptoOperator",
    "roles/containeranalysis.notes.attacher",
    "roles/containeranalysis.notes.occurrences.viewer",
    "roles/source.writer",
    "roles/storage.admin",
    "roles/cloudbuild.workerPoolUser",
    "roles/ondemandscanning.admin",
    "roles/logging.logWriter"
  ]
}

variable "labels" {
  description = <<-EOT
    A set of key/value label pairs to assign to the resources deployed by this blueprint.
    Labels must have the following minimum key/value pair:
    {
      app = "application_name"
      service = "application_servicea"
      env = "deployment environments"
    }
  EOT
  type        = map(string)
}
