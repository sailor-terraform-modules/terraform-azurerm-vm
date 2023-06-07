# Creates a Virtual Machine
resource "azurerm_windows_virtual_machine" "example" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  license_type          = var.license_type

  identity {
    type = "SystemAssigned"
  }
  os_disk {
    name                 = "${var.name}-disk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type #"Standard_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = var.publisher #MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:20348.1006.220908
    offer     = var.offer     #MicrosoftWindowsServer:WindowsServer:2019-datacenter-core-g2:17763.2686.220303
    sku       = var.sku       #MicrosoftWindowsServer:WindowsServer:2016-datacenter-gensecond:14393.5006.220305
    version   = var.storage_image_version
  }
  depends_on = [
    azurerm_network_interface.network_interface
  ]
}
# Creates Network Interface Card with private IP for Virtual Machine
resource "azurerm_network_interface" "network_interface" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
  }
}
# Creates Network Security Group NSG for Virtual Machine
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nic"
  location            = azurerm_windows_virtual_machine.example.location
  resource_group_name = azurerm_windows_virtual_machine.example.resource_group_name
}
# Creates Network Security Group Default Rules for Virtual Machine

resource "azurerm_network_security_rule" "nsg_rules" {
  for_each                    = var.nsg_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = each.value.source_port_range
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = each.value.destination_port_range
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_windows_virtual_machine.example.resource_group_name
}
# Creates association (i.e) adds NSG to the NIC
resource "azurerm_network_interface_security_group_association" "security_group_association" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Getting existing recovery_services_vault to add vm as a backup item 
data "azurerm_recovery_services_vault" "services_vault" {
  name                = var.recovery_services_vault_name
  resource_group_name = var.services_vault_resource_group_name
}
# Getting existing Backup Policy for Virtual Machine
data "azurerm_backup_policy_vm" "policy" {
  name                = "VM-backup-policy"
  recovery_vault_name = data.azurerm_recovery_services_vault.services_vault.name
  resource_group_name = data.azurerm_recovery_services_vault.services_vault.resource_group_name
}
# Creates Backup protected Virtual Machine
resource "azurerm_backup_protected_vm" "backup_protected_vm" {
  resource_group_name = data.azurerm_recovery_services_vault.services_vault.resource_group_name
  recovery_vault_name = data.azurerm_recovery_services_vault.services_vault.name
  source_vm_id        = azurerm_windows_virtual_machine.example.id
  backup_policy_id    = data.azurerm_backup_policy_vm.policy.id
  depends_on = [
    azurerm_windows_virtual_machine.example
  ]
}
