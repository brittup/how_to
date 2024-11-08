#PowerScale Terraform snippets
#Just open a TF file, type "pscale" and hit Ctrl+Space (make sure you have the Hashicorp Terraform extension installed for HCL language support)

#Requirements
#Make sure the language support extensions are supported.

#For Terraform (.TF files with HCL code) this works: https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform
#https://volumes.blog/2024/09/13/another-reason-to-adopt-visual-studio-code-for-infrastructure-as-code/


#https://dell.github.io/terraform-docs/docs/storage/platforms/powerscale/readme/


terraform {
  required_providers {
    powerscale = { 
      version = ">= 1.5.0"
      source = "registry.terraform.io/dell/powerscale"
    }
  }
}

