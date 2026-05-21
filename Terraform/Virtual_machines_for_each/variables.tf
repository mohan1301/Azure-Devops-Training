variable "location" {
  description = "location"
  type = string
  default = "canadacentral"
}

variable "environments" {
    description = "Map of environments and sizes"
    type = map(string)
    default = {
        "dev" = "Standard_D2s_v3"
        "qa" = "Standard_D2s_v3"
        "prod" = "Standard_D4s_v3"
     }
}

variable "adminusername" {
    description = "Admin username for VM"
    type = string
    default = "devopsuser"
}

variable "SSH_Key" {
    description = "SSH_Key"
    type = string
    default = "C:/Users/munag/.ssh/azure_vm_key.pub"
}

















# public needs to be sent to virtual machine and 
# private key needs to be there with us


#ssh-keygen -t rsa -b 4096 -C "devopsuser" -f "$HOME\.ssh\azure_vm_key"
# Key is stored in this location = C:\Users\munag\.ssh




