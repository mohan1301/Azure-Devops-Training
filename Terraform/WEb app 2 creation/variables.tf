variable "rgname" {
  description = "resource group name"
  type = string
  default = "ucwebrg"
}

variable "location" {
  description = "location name"
  default = "canadacentral"
  type = string
}

variable "asp" {
  default = "ucasp"
  description = "App Service Plan Name"
  type = string
}

variable "webapp" {
  description = "Web App Name"
  type = string
  default = "ucwebapp19891989" #Should be unique name
}

# Sequence of execution
# main.tf ---> variables.tf ---> resources.tf
