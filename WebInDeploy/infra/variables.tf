variable "BootstrapStorageAccount" {
  description = "Enter your Azure Storage Account:"
  default     = "cloudstorageazure"
}
variable "StorageAccountAccessKey" {
  description = "Paste your Azure Storage Account Access Key:"
  default     = "2bowzrRAQnU+WuqdUcQ3A/3jpYip0Jns+CNtt9BsxTQu8Q3qv4FjXm6KDtr7LkogGfoXnwpekSWoa4QAzbJtHw=="
}
variable "StorageAccountFileShare" {
  description = "Enter your Storage Acccount File Share name:"
  default     = "bootstrap"
}
variable "StorageAccountFileShareDirectory" {
  description = "Enter your Storage Account File Share Directory (if bootstrapping multiple firewalls):"
  default = "None"
}

variable "vnet_name" {
  description = "Enter a name for the transit VNET (i.e. transit-vnet):"
  default     = "Hub-VNET"
}

variable "vnet_cidr" {
  type        = "string"
  description = "Enter VNET Space:"
  default     = "10.0.0.0/16"
}

variable "spoke1-vnet_name" {
  description = "Enter a name for the Spoke1 VNET (i.e. transit-vnet):"
  default     = "Spoke1-VNET"
}

variable "spoke1-vnet_cidr" {
  type        = "string"
  description = "Enter VNET Space:"
  default     = "10.1.0.0/16"
}

variable "dns_servers" {
  type        = "list"
  description = "Enter IP od DNS Servers:"
  default     = ["8.8.8.8", "8.8.4.4"]
}
variable "resource_group" {
  description = "Enter new resource group name:"
  default     = "dstanic-dev-test-dev01"
}
variable "fw_bundle" {
  description = "Enter the firewall license type (byol, bundle1, or bundle2):"
  default     = "bundle2"
}
variable "adminuser" {}
variable "adminuserpassword" {}

variable "location" {}

variable "fw1_name" {}
variable "fw2_name" {}
variable "fw_size" {}
variable "panos_version" {}

variable "subnet0_name" {}
variable "subnet1_name" {}
variable "subnet2_name" {}
variable "subnet3_name" {}
variable "subnet0_cidr" {}
variable "subnet1_cidr" {}
variable "subnet2_cidr" {}
variable "subnet3_cidr" {}

variable "subnet10_name" {}
variable "subnet11_name" {}
variable "subnet12_name" {}
variable "subnet13_name" {}
variable "subnet10_cidr" {}
variable "subnet11_cidr" {}
variable "subnet12_cidr" {}
variable "subnet13_cidr" {}

# security group variables
variable "sg_name" {}
variable "sgrule1_name" {}
variable "sgrule2_name" {}

# network interfaces variables
variable "egresslb_ip" {}
//variable "fw1nic0_ip" {}
//variable "fw1nic1_ip" {}
//variable "fw1nic2_ip" {}
//variable "fw2nic0_ip" {}
//variable "fw2nic1_ip" {}
//variable "fw2nic2_ip" {}
variable "fw1nic0_name" {}
variable "fw1nic1_name" {}
variable "fw1nic2_name" {}
variable "fw2nic0_name" {}
variable "fw2nic1_name" {}
variable "fw2nic2_name" {}

# public IP variables
variable "fw1nic0pip_name" {}
variable "fw2nic0pip_name" {}
variable "fw1nic1pip_name" {}
variable "fw2nic1pip_name" {}

# availability Sets variables
variable "fwavset_name" {}

# egress load balancer variables
variable "egresslb_name" {}
variable "egresslbpool_name" {}
variable "egresslbfrontend_name" {}
variable "egresslbprobe_name" {}
variable "egresslbprobe_port" {}
variable "egresslbrule_name" {}

# public load balancers variables
variable "publiclb_name" {}
variable "publiclbfrontend_name" {}
variable "publiclbpool_name" {}
variable "publiclbprobe_port" {}
variable "publiclbprobe_name" {}
variable "publiclbrule1_name" {}
variable "publiclbrule1_port" {}
variable "publiclbrule2_name" {}
variable "publiclbrule2_port" {}
variable "publiclbpip_name" {}
