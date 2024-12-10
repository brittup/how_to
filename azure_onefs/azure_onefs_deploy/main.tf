module "powerscale" {
  source  = "dell/powerscale/azurerm"
  version = "1.0.0"
  # insert the required variables here

  
 
#prerequisites 
  image_id = "/subscriptions/8547234x-dhh6-4f6b-802d-ac3c6d976fgt/resourceGroups/azure_onefs_azure_ga981/providers/Microsoft.Compute/images/onefsimg"

  internal_nsg_name = "azure_ga981_internal_nsg"

  internal_nsg_resource_group = "azure_onefs_azure_ga981"

  internal_subnet_name = "onefs_internal_sb1"

  network_id = "/subscriptions/8547234x-dhh6-4f6b-802d-ac3c6d976fgt/resourceGroups/UDS_Network_RG/providers/Microsoft.Network/virtualNetworks/UDS_Lab_Virtual_Network"

  subscription_id ="8547234x-dhh6-4f6b-802d-ac3c6d976fgt"

  identity_list = ["/subscriptions/8547234x-dhh6-4f6b-802d-ac3c6d976fgt/resourcegroups/azure_onefs_azure_ga981/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azure_ga981_identity1"]
  
  external_nsg_name = "azure_ga981_external_nsg"

  external_nsg_resource_group = "azure_onefs_azure_ga981"

  external_subnet_name  = "onefs_external_sb1"

  cluster_name = "directga981"




  hashed_root_passphrase = "$5$6f3dbcd41f2e9155$IeA2ihbUflTDh4wWfFJbvaHVYXCkOdJoKpj/j/b5X82"

  hashed_admin_passphrase = "$5$6f3dbcd41f2e9155$IeA2ihbUflTDh4wWfFJbvaHVYXCkOdJoKpj/j/b5X82"


  #optionals
  #ssip will be -1 from offset
  addr_range_offset = 10

  data_disk_size = 1024

  data_disk_type = "Standard_LRS"

  data_disks_per_node = 5

  os_disk_type = "Standard_LRS"

  node_size = "Standard_D16ds_v5"

  resource_group = "azure_onefs_azure_ga981"

  smartconnect_zone = "scgaaz1.foo.com"

  timezone = "Eastern Time Zone"

  cluster_nodes = 4

  max_num_nodes = 18
}


#https://registry.terraform.io/modules/dell/powerscale/azurerm/latest?tab=inputs
#disk_type:
#Standard_LRS    : S : Standard HDD locally redundant storage. Best for backup, non-critical, and infrequent access - S40 – S70
#StandardSSD_LRS : E : Standard SSD locally redundant storage. Best for web servers, lightly used enterprise applications and dev/test - E20 – E70
#Premium_LRS     : P : Premium SSD locally redundant storage. Best for production and performance sensitive workloads - P20 – P70

#Ddv5-series: Standard_D32d_v5 and above   - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/ddv5-series?tabs=sizebasic#ddv5-series
#Ddsv5-series: Standard_D32ds_v5 and above - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/ddv5-series?tabs=sizebasic#ddsv5-series
#Edv5-series: Standard_E32d_v5 and above   - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/memory-optimized/edv5-series?tabs=sizebasic#edv5-series
#Edsv5-series: Standard_E32ds_v5 and above - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/memory-optimized/edv5-series?tabs=sizebasic#edsv5-series

# Hashed Password (Default)
# openssl passwd -5 -salt `head -c 8 /dev/random | xxd -p` "<replace-password-here>"
#default_hashed_password = "<default_hashed_password>"
# Hashed Password with different root and admin (Optional)
#hashed_admin_passphrase = "<hashed_admin_passphrase>"
#hashed_root_passphrase = "<hashed_admin_passphrase>"


