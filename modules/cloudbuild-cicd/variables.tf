
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

variable "app_github_remote_repo" {
  type        = string
  description = "Github remote repository uri"
}

variable "google_artifact_registry" {
  type = object({
    name   = string
    create = optional(bool, true)
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

variable "cloudbuildv2_connection_id" {
  type        = string
  description = "Cloudbuild V2 Connection ID for Github remote repository"
}
