data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "free" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = local.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
