locals {
  shape          = var.use_amd_micro ? "VM.Standard.E2.1.Micro" : "VM.Standard.A1.Flex"
  shape_suffix   = var.use_amd_micro ? "amd" : "a1"
  instance_count = var.use_amd_micro ? 2 : 1

  # Ampere A1 free-tier max: 2 OCPUs / 12 GB memory in a single instance.
  # AMD Micro free-tier max: 2 VM.Standard.E2.1.Micro instances.
  ocpus         = var.use_amd_micro ? null : 2
  memory_in_gbs = var.use_amd_micro ? null : 12

  # Always Free compute must be in the home region.
  # Micro instances can only be created in one availability domain.
  ad = data.oci_identity_availability_domains.ads.availability_domains[0].name
}
