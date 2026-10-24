variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user that owns the API key"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the OCI API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key (PEM) file"
  type        = string
}

variable "region" {
  description = "OCI home region where Always Free resources can be created"
  type        = string
  default     = "ap-hyderabad-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created (usually the root compartment for a personal account)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key string used to access the compute instances"
  type        = string
}

variable "project_name" {
  description = "Prefix used for resource display names"
  type        = string
  default     = "oracle-always-free"
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "use_amd_micro" {
  description = "If true, create VM.Standard.E2.1.Micro instances; otherwise create Ampere A1 Flex instances"
  type        = bool
  default     = false
}

variable "enable_block_volume" {
  type    = bool
  default = true
}

variable "enable_object_storage" {
  type    = bool
  default = true
}

variable "enable_load_balancer" {
  type    = bool
  default = true
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "enable_vault" {
  type    = bool
  default = true
}

variable "enable_bastion" {
  type    = bool
  default = true
}

variable "enable_autonomous_db" {
  description = "If true, create an Always Free Autonomous Database"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email address for monitoring alarm subscription (optional)"
  type        = string
  default     = ""
}

variable "autonomous_db_password" {
  description = "Admin password for the Always Free Autonomous Database (required when enable_autonomous_db is true; minimum 12 characters)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "email_domain_name" {
  description = "Custom domain for OCI Email Delivery (e.g. example.com). Leave empty to skip Email Delivery."
  type        = string
  default     = ""
}

variable "email_sender_address" {
  description = "Approved sender address for OCI Email Delivery. Defaults to noreply@<email_domain_name> if empty."
  type        = string
  default     = ""
}
