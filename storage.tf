resource "oci_core_volume" "free" {
  count = var.enable_block_volume ? 1 : 0

  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  display_name        = "${var.project_name}-volume"
  size_in_gbs         = 100
}

resource "oci_core_volume_attachment" "free" {
  count = var.enable_block_volume ? 1 : 0

  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.free[0].id
  volume_id       = oci_core_volume.free[0].id
}

resource "oci_objectstorage_bucket" "free" {
  count = var.enable_object_storage ? 1 : 0

  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.project_name}-bucket"
  access_type    = "NoPublicAccess"
}
