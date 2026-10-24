resource "oci_identity_dynamic_group" "capacity_checker" {
  count = var.use_amd_micro ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-capacity-checker"
  description    = "Dynamic group for AMD instances that check A1 capacity"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
}

resource "oci_identity_policy" "capacity_checker" {
  count = var.use_amd_micro ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-capacity-checker-policy"
  description    = "Allow AMD instances to check A1 capacity and publish notifications"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.capacity_checker[0].name} to manage compute-capacity-reports in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.capacity_checker[0].name} to use ons-topics in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.capacity_checker[0].name} to read ons-subscriptions in compartment id ${var.compartment_ocid}",
  ]
}
