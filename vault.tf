# vault_type = "VIRTUAL" is the standard (non-private) vault and is included in Always Free.
# Do NOT use "PRIVATE"; Virtual Private Vaults are billable.
resource "oci_kms_vault" "free" {
  count = var.enable_vault ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-vault"
  vault_type     = "VIRTUAL"
}

resource "oci_kms_key" "free" {
  count = var.enable_vault ? 1 : 0

  compartment_id      = var.compartment_ocid
  display_name        = "${var.project_name}-key"
  management_endpoint = oci_kms_vault.free[0].management_endpoint

  key_shape {
    algorithm = "AES"
    length    = 32
  }

  protection_mode = "SOFTWARE"
}

resource "oci_vault_secret" "free" {
  count = var.enable_vault ? 1 : 0

  compartment_id = var.compartment_ocid
  vault_id       = oci_kms_vault.free[0].id
  key_id         = oci_kms_key.free[0].id
  secret_name    = "${var.project_name}-secret"

  secret_content {
    content_type = "BASE64"
    content      = base64encode("This is a sample secret created by Terraform")
  }
}
