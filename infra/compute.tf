variable "availability_domain" {
  description = "The Availability Domain to provision the instance"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key for the debian user"
  type        = string
}

data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "local_file" "cloud_init" {
  filename = "${path.module}/cloud-init.yaml"
}

resource "oci_core_instance" "openclaw_instance" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = "openclaw-gateway"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_arm.images[0].id
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.openclaw_subnet.id
    display_name              = "openclaw-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(data.local_file.cloud_init.content)
  }
}

output "instance_public_ip" {
  value = oci_core_instance.openclaw_instance.public_ip
}
