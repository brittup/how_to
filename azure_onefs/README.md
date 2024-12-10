# The azure tf deployment code
The following files contain base example terraform deployment to enable the setup and implementation of a azure apex fs onefs cluster
<br>
<br>
https://registry.terraform.io/modules/dell/powerscale/azurerm/latest
<br>
<br>
It is a distillation of the deployment guide to it's simplest form, use in conjuction with that guide
<br>
<br>
Prequisites - cluster deployment code assumes these have been created and valid
<br>-resource group 
<br>-internal sg 
<br>-external sg
<br>-managed identity
<br>
<br>
* azure_prerequisites_tf_setup - contains sample tf code to create the base prerequisites, use this to create them


<br>

* azure_onefs_deploy - the main.tf deploy with examples

