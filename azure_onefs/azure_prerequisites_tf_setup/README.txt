### TF build to create Azure base requirements

-resource group 
-internal sg 
-external sg
-managed identity
Assumes deploy host is configured and setup for tf deployment of resources in Azure

customize main.tf as needed and modify for specific subscript id and role



-resource group - resource_group value

-internal sg - external_nsg_name value
-external sg - internal_nsg_name value

Both nsg are create and are very open:: any to any
custom nsg groups can be used with specific ports only, onefs security guide outlines ports needed
would require custom tf nsg creates <coming soon>


-managed identity with privileges based on role - required for network management and ssip; identity_list value



