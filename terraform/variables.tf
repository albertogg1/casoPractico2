# =============================================================
# vars.tf - Variables de la infraestructura
# =============================================================

# -------------------------------------------------------------
# AZURE - Credenciales
# -------------------------------------------------------------

variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
  sensitive   = true 
}

variable "tenant_id" {
  description = "ID del tenant de Azure"
  type        = string
  sensitive   = true
}


# -------------------------------------------------------------
# GENERAL
# -------------------------------------------------------------

variable "resource_group_name" {
  description = "Nombre del grupo de recursos que contendrá toda la infraestructura"
  type        = string
  default     = "rg-casopractico2"
}

variable "location" {
  description = "Región de Azure donde se desplegará la infraestructura"
  type        = string
  default     = "francecentral"
}

variable "environment" {
  description = "Etiqueta de entorno requerida en todos los recursos"
  type        = string
  default     = "casopractico2"
}

# -------------------------------------------------------------
# VM - Máquina Virtual
# -------------------------------------------------------------

variable "vm_size" {
  description = "Tamaño de la VM"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "admin_username" {
  description = "Usuario administrador de la VM Linux"
  type        = string
  default     = "azureuser"
}
