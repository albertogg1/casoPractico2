# IP pública de la VM
output "vm_public_ip" {
  description = "IP pública de la máquina virtual"
  value       = azurerm_public_ip.vm_pip.ip_address
}

# Comando SSH listo para conectarse
output "ssh_connection_command" {
  description = "Comando para conectarse a la VM por SSH"
  value       = "ssh -i private_key.pem ${var.admin_username}@${azurerm_public_ip.vm_pip.ip_address}"
}

# Clave privada SSH
output "ssh_private_key" {
  description = "Clave SSH privada para acceder a la VM"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}