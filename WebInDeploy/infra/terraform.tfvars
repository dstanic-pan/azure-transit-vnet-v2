

#Shared variables
location              = "west europe"

#Virtual Machine variables
fw1_name              = "VM-FW1"
fw2_name              = "VM-FW2"
fw_size               = "Standard_DS3_v2"
panos_version         = "latest"
//adminuser             = "paloalto"
//adminuserpassword     = "PanPassword123!"

# HUB-VNET variables
//vnet_name             = "transit-vnet"
vnet_cidr1            = "${split(",", var.vnet_cidr)}"
subnet0_name          = "fw-management"
subnet1_name          = "untrust"
subnet2_name          = "trust"
subnet3_name          = "lb-subnet"
//subnet0_cidr          = "10.0.0.0/24"
//subnet1_cidr          = "10.0.1.0/24"
//subnet2_cidr          = "10.0.2.0/24"
//subnet3_cidr          = "10.0.3.0/24"

# Spoke1-VNET variables
//vnet_name             = "transit-vnet"
spoke1-vnet_cidr1      = "${split(",", var.spoke1-vnet_cidr)}"
subnet10_name          = "web"
subnet11_name          = "app"
subnet12_name          = "db"
subnet13_name          = "dev"
//subnet10_cidr          = "10.1.0.0/24"
//subnet11_cidr          = "10.1.1.0/24"
//subnet12_cidr          = "10.1.2.0/24"
//subnet13_cidr          = "10.1.3.0/24"

# Security groups
sg_name               = "allow-all-security-group"
sgrule1_name          = "allow-all-inbound"
sgrule2_name          = "allow-all-outbound"

# Network Interfaces variables
//egresslb_ip           = "10.0.3.100"
fw1nic0_name          = "fw1-mgmt-nic"
fw1nic1_name          = "fw1-untrust-nic"
fw1nic2_name          = "fw1-trust-nic"
fw2nic0_name          = "fw2-mgmt-nic"
fw2nic1_name          = "fw2-untrust-nic"
fw2nic2_name          = "fw2-trust-nic"
//fw1nic0_ip            = "10.0.0.4"
//fw1nic1_ip            = "10.0.1.4"
//fw1nic2_ip            = "10.0.2.4"
//fw2nic0_ip            = "10.0.0.5"
//fw2nic1_ip            = "10.0.1.5"
//fw2nic2_ip            = "10.0.2.5"

# Public IP variables
fw1nic0pip_name       = "fw1-mgmt-pip"
fw2nic0pip_name       = "fw2-mgmt-pip"
fw1nic1pip_name       = "fw1-untrust-pip"
fw2nic1pip_name       = "fw2-untrust-pip"

# Availability Sets variables
fwavset_name          = "FW-AV-Set"

# Egress load balancer variables
egresslb_name         = "Internal-LB"
egresslbpool_name     = "fw-trust-backend-pool"
egresslbfrontend_name = "egress-lb-frontend-ip"
egresslbprobe_name    = "tcp-probe-22"
egresslbprobe_port    = 22
egresslbrule_name     = "allow-all"

#Public load balancers
publiclb_name         = "Public-LB"
publiclbpool_name     = "fw-untrust-backend-pool"
publiclbfrontend_name = "public-lb-frontend-ip"
publiclbprobe_name    = "tcp-probe-22"
publiclbprobe_port    = 22
publiclbrule1_name    = "allow-tcp-80"
publiclbrule1_port    = 80
publiclbrule2_name    = "allow-tcp-22"
publiclbrule2_port    = 22
publiclbpip_name      = "public-lb-pip"

#Route table variables
routetable1name       = "none"
