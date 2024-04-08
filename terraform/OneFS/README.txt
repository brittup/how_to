#####How to use the PowerScale OneFS tf 
#
#Files
1. main.tf         - main code blocks
2. variables.tf    - define cluster & variables
3. outputs.tf      - define output


###sample resource blocks here:
https://github.com/dell/terraform-provider-powerscale/tree/main/examples/resources


main.tf

terraform {
  required_providers {
    powerscale = { 
      version = "1.2.0"
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


##sample nfs export create block

resource "powerscale_nfs_export" "example_export" {
  # Required path for creating
  paths = ["/ifs/data"]



#######################################
#setup and validate
#######################################
terraform init
terraform validate
terraform plan


#create resources
terraform apply


#create all resources
terraform destroy
