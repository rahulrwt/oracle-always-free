data "oci_core_vnic_attachments" "free" {
  count = var.enable_load_balancer ? local.instance_count : 0

  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.free[count.index].id
}

data "oci_core_vnic" "free" {
  count = var.enable_load_balancer ? local.instance_count : 0

  vnic_id = data.oci_core_vnic_attachments.free[count.index].vnic_attachments[0].vnic_id
}

resource "oci_load_balancer_load_balancer" "free" {
  count = var.enable_load_balancer ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-lb"
  shape          = "flexible"
  subnet_ids     = [oci_core_subnet.public.id]

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }
}

resource "oci_load_balancer_backend_set" "http" {
  count = var.enable_load_balancer ? 1 : 0

  name             = "http-backend-set"
  load_balancer_id = oci_load_balancer_load_balancer.free[0].id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    port     = 80
    url_path = "/"
  }
}

resource "oci_load_balancer_backend" "free" {
  count = var.enable_load_balancer ? local.instance_count : 0

  load_balancer_id = oci_load_balancer_load_balancer.free[0].id
  backendset_name  = oci_load_balancer_backend_set.http[0].name
  ip_address       = data.oci_core_vnic.free[count.index].private_ip_address
  port             = 80
  weight           = 1
}

resource "oci_load_balancer_listener" "http" {
  count = var.enable_load_balancer ? 1 : 0

  load_balancer_id         = oci_load_balancer_load_balancer.free[0].id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.http[0].name
  port                     = 80
  protocol                 = "HTTP"
}
