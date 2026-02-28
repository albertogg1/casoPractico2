variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = "rg-casopractico2-albertogg1"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "casopractico2"
}