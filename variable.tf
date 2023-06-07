# virtual_machine
variable "name" {
  type        = string
  description = "Specifies the name of the Virtual Machine. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "name of the resource group"
}

variable "location" {
  type        = string
  description = "location of the resource group"
}



variable "size" {
  type        = string
  description = "Specifies the size of the Virtual Machine. See also Azure VM Naming Conventions."
}

variable "admin_username" {
  type        = string
  description = "Specifies the name of the local administrator account."
}

variable "admin_password" {
  type        = string
  description = "The password associated with the local administrator account."
}
variable "license_type" {
  type        = string
  description = "The pass"

}
# os_disk
variable "storage_account_type" {
  type        = string
  description = " Specifies the publisher of the image used to create the virtual machine. Examples: Canonical, MicrosoftWindowsServer"
  default     = "Standard_LRS"
}

variable "disk_size_gb" {
  type        = string
  description = "Specifies the offer of the image used to create the virtual machine. Examples: UbuntuServer, WindowsServer"
}

# source_image_reference
variable "publisher" {
  type        = string
  description = "Specifies the caching requirements for the Data Disk. Possible values include None, ReadOnly and ReadWrite."
  default     = "MicrosoftWindowsServer"
}

variable "offer" {
  type        = string
  description = "Specifies how the data disk should be created. Possible values are Attach, FromImage and Empty."
  default     = "WindowsServer"
}

variable "sku" {
  type        = string
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."

}

variable "storage_image_version" {
  type        = string
  description = "Specifies the Operating System on the OS Disk. Possible values are Linux and Windows."

}


# azurerm_network_interface
variable "ip_name" {
  type        = string
  description = "A name used for this IP Configuration."
  default     = "internal"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet where this Network Interface should be located in."
}

variable "private_ip_address_allocation" {
  type        = string
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static"
  default     = "Dynamic"
}
# azurerm_network_security_rule
variable "nsg_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    source_port_range          = string
    destination_address_prefix = string
    destination_port_range     = string
  }))
  default = {
    "https" = {
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "443"
      direction                  = "Inbound"
      name                       = "allow-https"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}
# azurerm_recovery_services_vault
variable "recovery_services_vault_name" {
  type        = string
  description = "name of the azurerm_network_security_group"
}
variable "services_vault_resource_group_name" {
  type        = string
  description = "name of the azurerm_network_security_group"
}