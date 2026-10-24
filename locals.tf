locals {
  shape        = var.use_amd_micro ? "VM.Standard.E2.1.Micro" : "VM.Standard.A1.Flex"
  shape_suffix = var.use_amd_micro ? "amd" : "a1"
  instance_count = 2

  # Ampere A1 free-tier total: 2 OCPUs / 12 GB memory.
  # Split across two instances so each is 1 OCPU / 6 GB.
  ocpus         = var.use_amd_micro ? null : 1
  memory_in_gbs = var.use_amd_micro ? null : 6

  # Always Free compute must be in the home region.
  # Micro instances can only be created in one availability domain.
  ad = data.oci_identity_availability_domains.ads.availability_domains[0].name
}
