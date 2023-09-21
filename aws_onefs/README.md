# The aws cli deployment templates
The following files contain simple basic aws CLI commands to enable the setup and implementation of a aws onefs cluster
<br>
<br>
It is a distillation of the deployment guide to it's simplest form, use in conjuction with that guide
<br>
<br>
* Dell PowerScale OneFS on AWS Deployment Note.xlsx -- is an xls tracking sheet for building cluster configs and tracking aws id
* onefs-runtime-assume-role.json -- assume role template required for deployment  
* onefs-runtime-policy.json -- runtime policy template required for deployment  
<br>

* CF -- contains a demo CoudFormation template and additional code snips
<br>
-cf templates - cloudformation templates
-ima.txt - deploy iam resources
-iam templates

<br>

* onefs-v2 -- contains the aws cli template scripts and required json mappings  
<br>

-aws-install-onefs-v2.txt  -- the aws cli command template to create and build all aws resources per the deployment guide 
-block-device-mappings-vonefs.json -- the block device mapping template used by each node  
-user-data-node-1-vonefs.json -- node1 bootstrap template used by node1
-user-data-node-2-vonefs.json -- node2 bootstrap template used by node2
-user-data-node-3-vonefs.json -- node3 bootstrap template used by node3
-user-data-node-4-vonefs.json -- node4 bootstrap template used by node4
-user-data-node-5-vonefs.json -- node5 bootstrap template used by node5
-user-data-node-6-vonefs.json -- node6 bootstrap template used by node6
