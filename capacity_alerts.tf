resource "oci_ons_notification_topic" "capacity" {
  count = var.use_amd_micro ? 1 : 0

  compartment_id = var.compartment_ocid
  name           = "${var.project_name}-capacity-alerts"
}

resource "oci_ons_subscription" "capacity" {
  count = var.use_amd_micro && var.notification_email != "" ? 1 : 0

  compartment_id = var.compartment_ocid
  topic_id       = oci_ons_notification_topic.capacity[0].id
  protocol       = "EMAIL"
  endpoint       = var.notification_email
}
