terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket   = "terraform-states"
    key      = "openclaw/terraform.tfstate"
    region   = "us-chicago-1"

    endpoints = {
      s3 = "https://axarqa6y0qva.compat.objectstorage.us-chicago-1.oraclecloud.com"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

provider "oci" {
  auth                = "SecurityToken"
  config_file_profile = "DEFAULT"
  region              = "us-chicago-1"
}
