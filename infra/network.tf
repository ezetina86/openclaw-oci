variable "compartment_id" {
  description = "The OCID of the compartment where resources will be created"
  type        = string
}

resource "oci_core_vcn" "openclaw_vcn" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "openclaw-vcn"
  dns_label      = "openclaw"
}

resource "oci_core_internet_gateway" "openclaw_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.openclaw_vcn.id
  display_name   = "openclaw-igw"
  enabled        = true
}

resource "oci_core_route_table" "openclaw_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.openclaw_vcn.id
  display_name   = "openclaw-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.openclaw_igw.id
  }
}

# checkov:skip=CKV_OCI_19: Public SSH access is required for initial bootstrap of this gateway instance
resource "oci_core_security_list" "openclaw_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.openclaw_vcn.id
  display_name   = "openclaw-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_subnet" "openclaw_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.openclaw_vcn.id
  cidr_block                 = "10.0.0.0/24"
  display_name               = "openclaw-public-subnet"
  dns_label                  = "public"
  route_table_id             = oci_core_route_table.openclaw_rt.id
  security_list_ids          = [oci_core_security_list.openclaw_sl.id]
  prohibit_public_ip_on_vnic = false
}
