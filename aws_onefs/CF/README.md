# The AWS CloudFormation POC deployment templates
The following files contain simple basic aws Cloudformation templates and CLI commands to enable the setup and implementation of a aws onefs cluster
<br>
<br>
IAM - contains the IAM cli code to create the required roles and profiles that are not created by the CF templates, required once per cluster
<br>
<br>
examples - contains some demo populated templates with sample data
<br>
<br>
* aws_onefs_cfv_1node_5vol__test_template.yaml - creates a 1 node test cluster; this template still creates interfaces for node 2-4 should they be needed later
* aws_onefs_cfv_4node_5vol_template.yaml - 4 + 5 ebs vol node cluster - - recommended POC testing template 
* aws_onefs_cfv_6node_20vol_template.yaml - MASTER - contains all resources for 6 node + 20 ebs vol cluster; remove nodes & volumes definitions as needed
* postCF.txt  - post deployment code and commands
<br>
<br>
<br>
<br>
templates provided as samples, no support






