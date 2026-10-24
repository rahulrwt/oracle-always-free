locals {
  email_sender = var.email_domain_name != "" ? coalesce(var.email_sender_address, "noreply@${var.email_domain_name}") : ""
}

resource "oci_email_email_domain" "this" {
  count = var.email_domain_name != "" ? 1 : 0

  compartment_id = var.compartment_ocid
  name           = var.email_domain_name
}

resource "oci_email_dkim" "this" {
  count = length(oci_email_email_domain.this)

  email_domain_id = oci_email_email_domain.this[0].id
}

resource "oci_email_sender" "this" {
  count = local.email_sender != "" ? 1 : 0

  compartment_id = var.compartment_ocid
  email_address  = local.email_sender
}
