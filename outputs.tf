output "availability_domain" {
  description = "Availability domain used for compute resources"
  value       = local.ad
}

output "instance_shape_used" {
  description = "The compute shape that was provisioned"
  value       = local.shape
}

output "instance_ocids" {
  description = "OCIDs of the compute instances"
  value       = oci_core_instance.free[*].id
}

output "instance_display_names" {
  description = "Display names of the compute instances"
  value       = oci_core_instance.free[*].display_name
}

output "instance_public_ips" {
  description = "Public IP addresses of the compute instances"
  value       = var.enable_load_balancer ? data.oci_core_vnic.free[*].public_ip_address : []
}

output "instance_private_ips" {
  description = "Private IP addresses of the compute instances"
  value       = var.enable_load_balancer ? data.oci_core_vnic.free[*].private_ip_address : []
}

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.this.id
}

output "subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public.id
}

output "block_volume_id" {
  description = "OCID of the block volume"
  value       = var.enable_block_volume ? oci_core_volume.free[0].id : null
}

output "object_storage_bucket" {
  description = "Name of the Object Storage bucket"
  value       = var.enable_object_storage ? oci_objectstorage_bucket.free[0].name : null
}

output "load_balancer_id" {
  description = "OCID of the Flexible Load Balancer"
  value       = var.enable_load_balancer ? oci_load_balancer_load_balancer.free[0].id : null
}

output "load_balancer_ip_addresses" {
  description = "IP addresses assigned to the load balancer"
  value       = var.enable_load_balancer ? oci_load_balancer_load_balancer.free[0].ip_address_details : []
}

output "notification_topic_id" {
  description = "OCID of the monitoring notification topic"
  value       = var.enable_monitoring ? oci_ons_notification_topic.free[0].id : null
}

output "vault_id" {
  description = "OCID of the KMS vault"
  value       = var.enable_vault ? oci_kms_vault.free[0].id : null
}

output "bastion_id" {
  description = "OCID of the bastion"
  value       = var.enable_bastion ? oci_bastion_bastion.free[0].id : null
}

output "autonomous_database_id" {
  description = "OCID of the Always Free Autonomous Database"
  value       = var.enable_autonomous_db ? oci_database_autonomous_database.free[0].id : null
}

output "email_domain_id" {
  description = "OCID of the Email Delivery domain"
  value       = var.email_domain_name != "" ? oci_email_email_domain.this[0].id : null
}

output "email_domain_verification_id" {
  description = "Domain verification ID to add as a DNS TXT record"
  value       = var.email_domain_name != "" ? oci_email_email_domain.this[0].domain_verification_id : null
}

output "email_dkim_record" {
  description = "DKIM DNS CNAME record that must be added for the email domain"
  value       = var.email_domain_name != "" ? { name = oci_email_dkim.this[0].dns_subdomain_name, value = oci_email_dkim.this[0].cname_record_value } : null
}

output "email_sender_address" {
  description = "Approved sender address for OCI Email Delivery"
  value       = local.email_sender != "" ? oci_email_sender.this[0].email_address : null
}

output "email_spf_record" {
  description = "Recommended SPF TXT record for the email domain"
  value       = var.email_domain_name != "" ? "v=spf1 include:rp.oracleemaildelivery.com ~all" : null
}
