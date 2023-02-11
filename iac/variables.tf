variable "source_repo_branch" {
  description = "Source repo branch"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Source repo name"
  type        = string
  default     = null
}

variable "s3_bucket_cache_name" {
  description = "Bucket stores build cache in S3"
  type        = string
  default     = null
}

variable "s3_bucket_artifact_name" {
  description = "Bucket stores build artifacts in S3"
  type        = string
  default     = null
}

variable "family" {
  description = "Family of the Task Definition"
  type        = string
  default     = "petclinic"
}

