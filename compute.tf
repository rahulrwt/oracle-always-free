resource "oci_core_instance" "free" {
  count               = local.instance_count
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  display_name        = "${var.project_name}-${local.shape_suffix}-${count.index + 1}"
  shape               = local.shape

  dynamic "shape_config" {
    for_each = var.use_amd_micro ? [] : [1]
    content {
      ocpus         = local.ocpus
      memory_in_gbs = local.memory_in_gbs
    }
  }

  source_details {
    source_id               = data.oci_core_images.free.images[0].id
    source_type             = "image"
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }

  preserve_boot_volume = false
}
