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

run "validate_a1_flex_shape" {
  command = plan

  assert {
    condition     = oci_core_instance.openclaw_instance.shape == "VM.Standard.A1.Flex"
    error_message = "The instance must use the Always Free ARM shape: VM.Standard.A1.Flex"
  }

  assert {
    condition     = oci_core_instance.openclaw_instance.shape_config[0].ocpus == 4
    error_message = "The instance must use exactly 4 OCPUs for Always Free compliance"
  }

  assert {
    condition     = oci_budget_budget.openclaw_spend_alert.amount == 1
    error_message = "The budget must be set to $1 to catch any unexpected spend"
  }

  assert {
    condition     = oci_budget_budget.openclaw_spend_alert.reset_period == "MONTHLY"
    error_message = "The budget must reset monthly"
  }
}
