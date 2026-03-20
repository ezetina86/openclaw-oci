mock_provider "oci" {}

override_data {
  target = data.oci_core_images.ubuntu_arm
  values = {
    images = [
      {
        id                       = "ocid1.image.oc1..mocked123"
        agent_features           = []
        base_image_id            = ""
        billable_size_in_gbs     = 0
        compartment_id           = ""
        create_image_allowed     = false
        defined_tags             = {}
        display_name             = ""
        freeform_tags            = {}
        image_source_details     = []
        instance_id              = ""
        launch_mode              = ""
        launch_options           = []
        listing_type             = ""
        operating_system         = ""
        operating_system_version = ""
        size_in_mbs              = "0"
        state                    = ""
        time_created             = ""
      }
    ]
  }
}

variables {
  compartment_id      = "ocid1.compartment.oc1..testing123"
  availability_domain = "XyzA:US-ASHBURN-AD-1"
  ssh_public_key      = "ssh-rsa AAAAB3NzaC1..."
  tenancy_ocid        = "ocid1.tenancy.oc1..testing123"
  budget_alert_email  = "test@example.com"
}

run "validate_vcn" {
  command = plan

  assert {
    condition     = oci_core_vcn.openclaw_vcn.cidr_blocks[0] == "10.0.0.0/16"
    error_message = "The VCN must use the 10.0.0.0/16 CIDR block for safety"
  }

  assert {
    condition     = oci_core_subnet.openclaw_subnet.cidr_block == "10.0.0.0/24"
    error_message = "The public subnet must use the 10.0.0.0/24 CIDR block"
  }

  assert {
    condition     = oci_core_subnet.openclaw_subnet.prohibit_public_ip_on_vnic == false
    error_message = "The public subnet must allow public IPs for the Cloudflare tunnel"
  }
}
