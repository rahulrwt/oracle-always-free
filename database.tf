resource "oci_database_autonomous_database" "free" {
  count = var.enable_autonomous_db ? 1 : 0

  compartment_id           = var.compartment_ocid
  db_name                  = lower(replace("${var.project_name}db", "-", ""))
  display_name             = "${var.project_name}-adb"
  db_workload              = "OLTP"
  is_free_tier             = true
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
  license_model            = "LICENSE_INCLUDED"
  admin_password           = var.autonomous_db_password != "" ? var.autonomous_db_password : null
}
