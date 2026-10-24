resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.project_name}-vcn"
  dns_label      = "freevcn"
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.project_name}-igw"
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.project_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.project_name}-public-sl"

  # SSH only from the user-specified CIDR block (empty = no SSH ingress)
  dynamic "ingress_security_rules" {
    for_each = var.allowed_ssh_cidr != "" ? [var.allowed_ssh_cidr] : []
    content {
      protocol = "6" # TCP
      source   = ingress_security_rules.value
      tcp_options {
        min = 22
        max = 22
      }
    }
  }

  # HTTP from the internet
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS from the internet (only when a certificate is supplied)
  dynamic "ingress_security_rules" {
    for_each = var.lb_certificate_private_key != "" && var.lb_certificate_public_certificate != "" ? [1] : []
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        min = 443
        max = 443
      }
    }
  }

  # LB health checks from within the VCN
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options {
      min = 80
      max = 80
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "public" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.this.id
  cidr_block          = var.public_subnet_cidr
  availability_domain = local.ad
  display_name        = "${var.project_name}-public-subnet"
  route_table_id      = oci_core_route_table.public.id
  security_list_ids   = [oci_core_security_list.public.id]
  dns_label           = "public"
}
