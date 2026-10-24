resource "oci_bastion_bastion" "free" {
  count = var.enable_bastion ? 1 : 0

  bastion_type     = "STANDARD"
  compartment_id   = var.compartment_ocid
  target_subnet_id = oci_core_subnet.public.id
  name             = "${var.project_name}-bastion"

  client_cidr_block_allow_list = ["0.0.0.0/0"]
  max_session_ttl_in_seconds   = 1800
}
