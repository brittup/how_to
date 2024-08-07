# The aws cli deployment templates
The following files contain simple basic aws CLI commands to enable the setup and implementation of a aws onefs cluster
<br>
<br>
It is a distillation of the deployment guide to it's simplest form, use in conjuction with that guide
<br>
<br>
* Prequisites - contains the template files for IAM resources
- Dell PowerScale OneFS on AWS Deployment Note.xlsx -- is an xls tracking sheet for building cluster configs and tracking aws id
-  onefs-runtime-assume-role.json -- assume role template required for deployment  
- onefs-runtime-policy.json -- runtime policy template required for deployment  
<br>

* CF -- contains a demo CoudFormation template and additional code snips


<br>

* cli -- contains the aws cli template scripts and required json mappings  

<br>

* TF -- contains sample tf modules and code to build a cluster