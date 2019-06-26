resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

################################################################################

# Create a hub virtual network within the resource group
resource "azurerm_virtual_network" "VNET1" {
  name                = "${var.vnet_name}"
  address_space       = "${split(",", var.vnet_cidr)}"
  dns_servers         = "${var.dns_servers}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "fw-management" {
  name                 = "${var.subnet0_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.VNET1.name}"
  address_prefix       = "${var.subnet0_cidr}"
}
#resource "azurerm_subnet_route_table_association" "rta-management" {
#  subnet_id      = "${azurerm_subnet.management.id}"
#  route_table_id = "${azurerm_route_table.rt-management.id}"
#}
resource "azurerm_subnet" "untrust" {
  name                 = "${var.subnet1_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.VNET1.name}"
  address_prefix       = "${var.subnet1_cidr}"
}

resource "azurerm_subnet" "trust" {
  name                 = "${var.subnet2_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.VNET1.name}"
  address_prefix       = "${var.subnet2_cidr}"
}
resource "azurerm_subnet" "lb-subnet" {
  name                 = "${var.subnet3_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.VNET1.name}"
  address_prefix       = "${var.subnet3_cidr}"
}
  ################################################################################

# Create a route table for Web subnet
resource "azurerm_route_table" "rt-websubnet" {
  name                = "RT-WebSubnet"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  route {
    name                   = "rt-default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.egresslb_ip}"
  }
 route {
    name                   = "rt-app-subnet"
    address_prefix         = "${var.subnet11_cidr}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.egresslb_ip}"
  }
 route {
    name                   = "rt-db-subnet"
    address_prefix         = "${var.subnet12_cidr}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.egresslb_ip}"
  }
   route {
    name                   = "rt-dev-subnet"
    address_prefix         = "${var.subnet13_cidr}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.egresslb_ip}"
  }
}

# Create a route table for Dev subnet
resource "azurerm_route_table" "rt-devsubnet" {
  name                = "RT-DevSubnet"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  route {
    name                   = "rt-default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.egresslb_ip}"
  }
  route {
    name                   = "rt-web-subnet"
    address_prefix         = "${var.subnet10_cidr}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.egresslb_ip}"
  }
    route {
    name                   = "rt-app-subnet"
    address_prefix         = "${var.subnet11_cidr}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.egresslb_ip}"
  }
    route {
    name                   = "rt-db-subnet"
    address_prefix         = "${var.subnet12_cidr}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.egresslb_ip}"
  }
}
# Create a spoke1 virtual network within the resource group
resource "azurerm_virtual_network" "VNET2" {
  name                = "${var.spoke1-vnet_name}"
  address_space       = "${split(",", var.spoke1-vnet_cidr)}"
  dns_servers         = "${var.dns_servers}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "web" {
  name                 = "${var.subnet10_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.VNET2.name}"
  address_prefix       = "${var.subnet10_cidr}"
}
resource "azurerm_subnet_route_table_association" "rta-web" {
  subnet_id      = "${azurerm_subnet.web.id}"
  route_table_id = "${azurerm_route_table.rt-websubnet.id}"

  depends_on          = ["azurerm_virtual_machine.spoke1-web",
                         "azurerm_virtual_machine.vmfw1",
                         "azurerm_virtual_machine.vmfw2"]
}
resource "azurerm_subnet" "app" {
  name                 = "${var.subnet11_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.VNET2.name}"
  address_prefix       = "${var.subnet11_cidr}"
}

resource "azurerm_subnet" "db" {
  name                 = "${var.subnet12_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.VNET2.name}"
  address_prefix       = "${var.subnet12_cidr}"
}
resource "azurerm_subnet" "dev" {
  name                 = "${var.subnet13_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.VNET2.name}"
  address_prefix       = "${var.subnet13_cidr}"}

  //depends_on          = ["azurerm_virtual_network.VNET1",
  //                       "azurerm_lb.egresslb"]

resource "azurerm_subnet_route_table_association" "rta-dev" {
  subnet_id      = "${azurerm_subnet.dev.id}"
  route_table_id = "${azurerm_route_table.rt-devsubnet.id}"

}
  ################################################################################
# Create VNNET Peering between Hub-VNET and Spoke1-VNET
resource "azurerm_virtual_network_peering" "peer-vnet1" {
  name                      = "Hub-VNet-to-Spoke1-VNet"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.VNET1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.VNET2.id}"
  allow_virtual_network_access = "true"
  allow_forwarded_traffic = "true"
}

resource "azurerm_virtual_network_peering" "peer-vnet2" {
  name                      = "Spoke1-VNet-to-Hub-VNet"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.VNET2.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.VNET1.id}"
  allow_virtual_network_access = "true"
  allow_forwarded_traffic = "true"

   depends_on          = ["azurerm_virtual_network.VNET1",
                         "azurerm_virtual_network.VNET1"]
}

resource "azurerm_network_security_group" "sg" {
  name                = "${var.sg_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "${var.sgrule1_name}"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "${var.sgrule2_name}"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

################################################################################
################################################################################

resource "azurerm_availability_set" "fwavset" {
  name                         = "${var.fwavset_name}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}

################################################################################
################################################################################

resource "azurerm_lb" "egresslb" {
  name                = "${var.egresslb_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  sku                 = "standard"

  frontend_ip_configuration {
    name                          = "${var.egresslbfrontend_name}"
    subnet_id      = "${azurerm_subnet.lb-subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.egresslb_ip}"
  }
}

resource "azurerm_lb_backend_address_pool" "egresslbbackend" {
  name                = "${var.egresslbpool_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.egresslb.id}"

}

resource "azurerm_lb_rule" "egresslbrule" {
  name                           	= "${var.egresslbrule_name}"
  resource_group_name            	= "${azurerm_resource_group.rg.name}"
  loadbalancer_id                	= "${azurerm_lb.egresslb.id}"
  protocol                       	= "All"
  frontend_port                  	= 0
  backend_port                   	= 0
  frontend_ip_configuration_name 	= "${var.egresslbfrontend_name}"
  backend_address_pool_id 				= "${azurerm_lb_backend_address_pool.egresslbbackend.id}"
  probe_id												= "${azurerm_lb_probe.egresslbprobe.id}"
  enable_floating_ip              = true
}

resource "azurerm_lb_probe" "egresslbprobe" {
  name                = "${var.egresslbprobe_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.egresslb.id}"
  port                = "${var.egresslbprobe_port}"
}

################################################################################
################################################################################

resource "azurerm_public_ip" "publiclbpip" {
  name                         = "${var.publiclb_name}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  sku                          = "standard"
}

resource "azurerm_lb" "publiclb" {
  name                  = "${var.publiclb_name}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  sku                   = "standard"

  frontend_ip_configuration {
    name                 = "${var.publiclbfrontend_name}"
    public_ip_address_id = "${azurerm_public_ip.publiclbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "publiclbbackend" {
  name                = "${var.publiclbpool_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.publiclb.id}"
}

resource "azurerm_lb_probe" "publiclbprobe" {
  name                = "${var.publiclbprobe_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.publiclb.id}"
  port                = "${var.publiclbprobe_port}"
}

resource "azurerm_lb_rule" "publiclbrule1" {
  name                           	= "${var.publiclbrule1_name}"
  resource_group_name            	= "${azurerm_resource_group.rg.name}"
  loadbalancer_id                	= "${azurerm_lb.publiclb.id}"
  protocol                       	= "Tcp"
  frontend_port                  	= "${var.publiclbrule1_port}"
  backend_port                   	= "${var.publiclbrule1_port}"
  frontend_ip_configuration_name 	= "${var.publiclbfrontend_name}"
  backend_address_pool_id 				= "${azurerm_lb_backend_address_pool.publiclbbackend.id}"
  probe_id												= "${azurerm_lb_probe.publiclbprobe.id}"
  enable_floating_ip              = "true"
}

resource "azurerm_lb_rule" "publiclbrule2" {
  name                           	= "${var.publiclbrule2_name}"
  resource_group_name            	= "${azurerm_resource_group.rg.name}"
  loadbalancer_id                	= "${azurerm_lb.publiclb.id}"
  protocol                       	= "Tcp"
  frontend_port                  	= "${var.publiclbrule2_port}"
  backend_port                   	= "${var.publiclbrule2_port}"
  frontend_ip_configuration_name 	= "${var.publiclbfrontend_name}"
  backend_address_pool_id 				= "${azurerm_lb_backend_address_pool.publiclbbackend.id}"
  probe_id												= "${azurerm_lb_probe.publiclbprobe.id}"
  enable_floating_ip              = "true"
}

################################################################################
################################################################################

resource "azurerm_public_ip" "fw1nic0pip" {
  name                         = "${var.fw1nic0pip_name}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  sku                          = "standard"
}

resource "azurerm_public_ip" "fw1nic1pip" {
  name                         = "${var.fw1nic1pip_name}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  sku                          = "standard"
}

resource "azurerm_network_interface" "fw1nic0" {
  name                      = "${var.fw1nic0_name}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id      = "${azurerm_subnet.fw-management.id}"
    private_ip_address_allocation = "dynamic"
    //private_ip_address						= "${var.fw1nic0_ip}"
    public_ip_address_id          = "${azurerm_public_ip.fw1nic0pip.id}"
  }
}

resource "azurerm_network_interface" "fw1nic1" {
  name                      = "${var.fw1nic1_name}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id      = "${azurerm_subnet.untrust.id}"
    private_ip_address_allocation           = "dynamic"
    //private_ip_address						          = "${var.fw1nic1_ip}"
    public_ip_address_id                    = "${azurerm_public_ip.fw1nic1pip.id}"
    load_balancer_backend_address_pools_ids	= ["${azurerm_lb_backend_address_pool.publiclbbackend.id}"]
  }
}

################################################################################
################################################################################

resource "azurerm_network_interface" "fw1nic2" {
  name                      = "${var.fw1nic2_name}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id      = "${azurerm_subnet.trust.id}"
    private_ip_address_allocation           = "dynamic"
    //private_ip_address						          = "${var.fw1nic2_ip}"
    load_balancer_backend_address_pools_ids	= ["${azurerm_lb_backend_address_pool.egresslbbackend.id}"]
  }
}

resource "azurerm_virtual_machine" "vmfw1" {
  name                = "${var.fw1_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  vm_size             = "${var.fw_size}"
  availability_set_id = "${azurerm_availability_set.fwavset.id}"

  depends_on          = ["azurerm_network_interface.fw1nic0",
                         "azurerm_network_interface.fw1nic1",
                         "azurerm_network_interface.fw1nic2"]

  plan {
    name      = "${var.fw_bundle}"
    publisher = "paloaltonetworks"
    product   = "vmseries1"
  }

  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = "${var.fw_bundle}"
    version   = "${var.panos_version}"
  }

  storage_os_disk {
    name              = "${join("", list(var.fw1_name, "-osdisk"))}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.fw1_name}"
    admin_username = "${var.adminuser}"
    admin_password = "${var.adminuserpassword}"
    custom_data    = "${join(",", list("storage-account=${var.BootstrapStorageAccount}", "access-key=${var.StorageAccountAccessKey}", "file-share=${var.StorageAccountFileShare}", "share-directory=${var.StorageAccountFileShareDirectory}"))}"
  }

  primary_network_interface_id = "${azurerm_network_interface.fw1nic0.id}"
  network_interface_ids        = ["${azurerm_network_interface.fw1nic0.id}",
                                  "${azurerm_network_interface.fw1nic1.id}",
                                  "${azurerm_network_interface.fw1nic2.id}"]

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

################################################################################
################################################################################

resource "azurerm_public_ip" "fw2nic0pip" {
  name                         = "${var.fw2nic0pip_name}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  sku                          = "standard"
 }

resource "azurerm_public_ip" "fw2nic1pip" {
  name                         = "${var.fw2nic1pip_name}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  sku                          = "standard"
}

resource "azurerm_network_interface" "fw2nic0" {
  name                      = "${var.fw2nic0_name}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id      = "${azurerm_subnet.fw-management.id}"
    private_ip_address_allocation = "dynamic"
    //private_ip_address						= "${var.fw2nic0_ip}"
    public_ip_address_id          = "${azurerm_public_ip.fw2nic0pip.id}"
  }
}

resource "azurerm_network_interface" "fw2nic1" {
  name                      = "${var.fw2nic1_name}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id      = "${azurerm_subnet.untrust.id}"
    private_ip_address_allocation           = "dynamic"
    //private_ip_address						          = "${var.fw2nic1_ip}"
    public_ip_address_id                    = "${azurerm_public_ip.fw2nic1pip.id}"
    load_balancer_backend_address_pools_ids	= ["${azurerm_lb_backend_address_pool.publiclbbackend.id}"]
  }
}

resource "azurerm_network_interface" "fw2nic2" {
  name                      = "${var.fw2nic2_name}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id      = "${azurerm_subnet.trust.id}"
    private_ip_address_allocation           = "dynamic"
    //private_ip_address						          = "${var.fw2nic2_ip}"
    load_balancer_backend_address_pools_ids	= ["${azurerm_lb_backend_address_pool.egresslbbackend.id}"]
  }
}

resource "azurerm_virtual_machine" "vmfw2" {
  name                = "${var.fw2_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  vm_size             = "${var.fw_size}"
  availability_set_id = "${azurerm_availability_set.fwavset.id}"

  depends_on          = ["azurerm_network_interface.fw2nic0",
                         "azurerm_network_interface.fw2nic1",
                         "azurerm_network_interface.fw2nic2"]

  plan {
    name      = "${var.fw_bundle}"
    publisher = "paloaltonetworks"
    product   = "vmseries1"
  }

  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = "${var.fw_bundle}"
    version   = "${var.panos_version}"
  }

  storage_os_disk {
    name              = "${join("", list(var.fw2_name, "-osdisk"))}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.fw2_name}"
    admin_username = "${var.adminuser}"
    admin_password = "${var.adminuserpassword}"
    custom_data    = "${join(",", list("storage-account=${var.BootstrapStorageAccount}", "access-key=${var.StorageAccountAccessKey}", "file-share=${var.StorageAccountFileShare}", "share-directory=${var.StorageAccountFileShareDirectory}"))}"
  }

  primary_network_interface_id = "${azurerm_network_interface.fw2nic0.id}"
  network_interface_ids        = ["${azurerm_network_interface.fw2nic0.id}",
                                  "${azurerm_network_interface.fw2nic1.id}",
                                  "${azurerm_network_interface.fw2nic2.id}"]

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


data "template_file" "web1_config" {
  template = "${file("${path.module}/web1-config.yml.tpl")}"
}

# Create Web server in Spoke1-VNET
resource "azurerm_network_interface" "spoke1-web-nic0" {
  name                = "web1-nic0"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.web.id}"
    private_ip_address_allocation = "dynamic"
  }
}
resource "azurerm_virtual_machine" "spoke1-web" {
  name                  					 = "Web1"
  location              					 = "${azurerm_resource_group.rg.location}"
  resource_group_name   					 = "${azurerm_resource_group.rg.name}"
  network_interface_ids 					 = ["${azurerm_network_interface.spoke1-web-nic0.id}"]
  vm_size               					 = "Standard_DS1_v2"
  delete_os_disk_on_termination 	 = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdiskweb1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Web1"
    admin_username = "${var.adminuser}"
    admin_password = "${var.adminuserpassword}"
    # Pulls web1-config.yml.tpl file to pre-configure the Ubuntu server with Apache with a blue page.
    custom_data    = "${base64encode(data.template_file.web1_config.rendered)}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Create Dev server in Spoke1-VNET
resource "azurerm_network_interface" "spoke1-dev01-nic0" {
  name                = "dev1-nic0"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.dev.id}"
    private_ip_address_allocation = "dynamic"
  }
}
resource "azurerm_virtual_machine" "spoke1-dev01" {
  name                  					 = "Dev1"
  location              					 = "${azurerm_resource_group.rg.location}"
  resource_group_name   					 = "${azurerm_resource_group.rg.name}"
  network_interface_ids 					 = ["${azurerm_network_interface.spoke1-dev01-nic0.id}"]
  vm_size               					 = "Standard_DS1_v2"
  delete_os_disk_on_termination 	 = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdiskdev1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Dev1"
    admin_username = "${var.adminuser}"
    admin_password = "${var.adminuserpassword}"
    # Pulls web1-config.yml.tpl file to pre-configure the Ubuntu server with Apache with a blue page.
    #custom_data    = "${base64encode(data.template_file.web1_config.rendered)}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

#  Outputs to the console
output "" {
  value = "= = =The firewalls may take up to 5 minutes to finish deploying.  You can proceed with additional steps once you can access the GUI= = = ="
}

output "a) USERNAME    " {
  value = "${var.adminuser}"
}

output "b) PASSWORD    " {
  value = "${var.adminuserpassword}"
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

output "g) WEB SUBNET CIDR" {
  value  = "${var.subnet10_cidr}"
}

output "h) DEV SUBNET CIDR" {
  value  = "${var.subnet13_cidr}"
}

output "i) IP WEB1" {
  value  = "${azurerm_network_interface.spoke1-web-nic0.private_ip_address}"
}

output "j) IP DEV" {
  value  = "${azurerm_network_interface.spoke1-dev01-nic0.private_ip_address}"
}
