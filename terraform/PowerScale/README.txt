#####How to use the PowerScale OneFS tf 

https://registry.terraform.io/providers/dell/powerscale/latest

#Files
1. main.tf         - main code blocks
2. variables.tf    - define cluster & variables
3. outputs.tf      - define output


###sample resource blocks here:
https://github.com/dell/terraform-provider-powerscale/tree/main/examples/resources


mkdir tf
cd tf


vi main.tf
vi variables.tf
vi outputs.tf


###main.tf

terraform {
  required_providers {
    powerscale = { 
      version = "1.4.0"
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

##sample nfs export create block - added to outputs.tf 

resource "powerscale_nfs_export" "example_export" {
  # Required path for creating
  paths = ["/ifs/data"]
}








#######################################
install tf for democenter
#######################################
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform
terraform -help


###old install
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform


#######################################
#setup and validate
#######################################
terraform init
terraform validate
terraform plan
terraform init -upgrade


#create resources
terraform apply


#create all resources
terraform destroy





