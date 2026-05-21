variable "vm_count" {
  type        = number
  default     = 3
  description = "Number of VMs to create"
}

variable "location" {
  default = "canadacentral"
  type = string
  description = "location value"
}
variable "vm-size" {
    description = "vm size"
    type = string
    default = "Standard_D2s_v3"
}

variable "adminusername" {
    description = "Admin username for VM"
    type = string
    default = "devopsuser"
}

variable "adminpassword" {
    description = "Adminpassword"
    type = string
    default = "Password1234"
}

variable "SSH_Key" {
    description = "SSH_key"
    type = string
    default = "C:/Users/munag/.ssh/azure_vm_key.pub"

}