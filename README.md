# Azure Transit VNET Framework

# Brief Description
Azure Transit VNET, Hub and Spoke LB Sandwich architecture built as one Skillet Collection with Six Skillets that cover Infrastructure, Inbound, Outbound and East-West use cases.

# Skillet Details
Authoring Group: Public Cloud  
Documentation:  https://github.com/dstanic-pan/azure-transit-vnet-v2/tree/master/Documentation  
PAN-OS Supported:  8.1, 9.0  
Cloud Provider(s) Supported:  Azure  
Type of Skillet:  terraform, python3l, panos  
Purpose:  Demo  

# Detail Description
Azure Transit VNET is a solution that consists of one skillet collection with six skillets. It provides a very flexible and efficient way to deploy and test most requested Azure architecture and ensures that all best practices are being met. Overall solution provides one simple framework to easily deploy VM-Series load Balancing Sandwich architecture with two test instances distributed across two subnets of Spoke VNET. 
Depending on the needs it is possible to configure and test Inbound, Outbound and East-West use cases. 

![alt text](https://raw.githubusercontent.com/dstanic-pan/azure-transit-vnet-v2/master/architecture-diagram.png)

# Support Policy
The code and templates in the repo are released under an as-is, best effort, support policy. These scripts should be seen as community supported and Palo Alto Networks will contribute our expertise as and when possible. We do not provide technical support or help in using or troubleshooting the components of the project through our normal support options such as Palo Alto Networks support teams, or ASC (Authorized Support Centers) partners and backline support options. The underlying product used (the VM-Series firewall) by the scripts or templates are still supported, but the support is only for the product functionality and not for help in deploying or using the template or script itself. Unless explicitly tagged, all projects or work posted in our GitHub repository (at https://github.com/PaloAltoNetworks) or sites other than our official Downloads page on https://support.paloaltonetworks.com are provided under the best effort policy.
