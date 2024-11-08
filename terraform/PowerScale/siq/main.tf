terraform {
  required_providers {
    powerscale = {
      version = ">=1.5.0"
      source = "registry.terraform.io/dell/powerscale"
    }
  }
}

provider "powerscale" {
  username = var.username
  password = var.password
  endpoint = var.endpoint
  insecure = var.insecure
}



#https://dell.github.io/terraform-docs/docs/storage/platforms/powerscale/product_guide/resources/synciq_policy/
resource "powerscale_synciq_policy" "policy" {
  # Required
  name             = "policy-tftest1"
  action           = "sync"
  source_root_path = "/ifs/ps1"
  target_host      = "192.168.1.200"
  target_path      = "/ifs/ps1"
 

  source_network = {
    pool   = "pool0"
    subnet = "subnet0"
  }
}





/*
is SIQ setup and running
isi services -a | grep isi_migrate enable
isi services -a isi_migrate enable
isi_for_array -s /usr/bin/isi_migr_sched
isi_for_array -s ps auwx | grep isi_migr_sched
isi sync setting mod --encryption-required=false
*/
