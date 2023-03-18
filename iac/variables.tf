variable "source_repo_branch" {
  description = "Source repo branch"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Source repository names / resources names"
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

variable "cidr_block" {
  description = "Classless Inter-Domain Routing range of the VPC"
  type        = string
  default     = null
}

variable "public_cidr" {
  description = "List of public cidr blocks"
  type        = map(any)
  default     = null
}

variable "private_cidr" {
  description = "List of private cidr blocks"
  type        = map(any)
  default     = null
}

variable "gateway_endpoint_services" {
  description = "List of gateway endpoint"
  type        = list(any)
  default     = null
}

variable "gateway_endpoint_interface" {
  description = "List of interface endpoint"
  type        = list(any)
  default     = null
}

variable "endpoint_interface_ports" {
  description = "List of interface endpoint ports"
  type        = list(any)
  default     = null
}

variable "database_username" {
  description = "Name of the database username"
  type        = string
  default     = null
}

variable "db_instance_type" {
  description = "Database instance type"
  type        = string
  default     = null
}

variable "storage_type" {
  description = "Database storage type"
  type        = map(any)
  default     = null
}

variable "db_availability_zone" {
  description = "Database availability zone"
  type        = string
  default     = null
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}
