output "RESOURCE_GROUP_NAME" {
  value = "${azurerm_resource_group.rg.name}"
}

output "a) USERNAME    " {
  value = "${var.username}"
}

output "b) PASSWORD    " {
  value = "${var.password}"
}

output "c) PUBLIC IP FW1 MGMT " {
  value = "${azurerm_public_ip.fw1nic0pip.ip_address}"
}

output "d) PUBLIC IP FW2 MGMT " {
  value = "${azurerm_public_ip.fw2nic0pip.ip_address}"
}

output "e) PUBLIC LB IP" {
  value  = "${azurerm_public_ip.publiclbpip.ip_address}"
}

output "f) EGRESS LB IP" {
  value  = "${var.egresslb_ip}"
}

output "g) HUB VNET CIDR" {
  value  = "${var.vnet_cidr}"
}

output "h) UNTRUST SUBNET CIDR" {
  value  = "${var.subnet1_cidr}"
}

output "i) TRUST SUBNET CIDR" {
  value  = "${var.subnet2_cidr}"
}

output "j) SPOKE1 VNET CIDR" {
  value  = "${var.spoke1_vnet_cidr}"
}

output "k) WEB SUBNET CIDR" {
  value  = "${var.subnet10_cidr}"
}

output "l) APP SUBNET CIDR" {
  value  = "${var.subnet11_cidr}"
}

output "m) DB SUBNET CIDR" {
  value  = "${var.subnet12_cidr}"
}

output "n) DEV SUBNET CIDR" {
  value  = "${var.subnet13_cidr}"
}

output "o) IP WEB1" {
  value  = "${azurerm_network_interface.spoke1-web-nic0.private_ip_address}"
}

output "p) IP DEV" {
  value  = "${azurerm_network_interface.spoke1-dev01-nic0.private_ip_address}"
}
