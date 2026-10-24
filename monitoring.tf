resource "oci_ons_notification_topic" "free" {
  count = var.enable_monitoring ? 1 : 0

  compartment_id = var.compartment_ocid
  name           = "${var.project_name}-topic"
}

resource "oci_ons_subscription" "free" {
  count = var.enable_monitoring && var.notification_email != "" ? 1 : 0

  compartment_id = var.compartment_ocid
  topic_id       = oci_ons_notification_topic.free[0].id
  protocol       = "EMAIL"
  endpoint       = var.notification_email
}

resource "oci_monitoring_alarm" "high_cpu" {
  count = var.enable_monitoring ? 1 : 0

  compartment_id        = var.compartment_ocid
  destinations          = [oci_ons_notification_topic.free[0].id]
  display_name          = "${var.project_name}-high-cpu"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_computeagent"
  query                 = "CpuUtilization[1m].mean() > 80"
  severity              = "WARNING"
}
