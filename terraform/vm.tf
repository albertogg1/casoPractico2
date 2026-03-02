# =============================================================
# vm.tf - Máquina Virtual Linux en Azure
# =============================================================
# Este fichero crea todos los recursos necesarios para tener
# una VM Linux accesible desde internet por SSH y HTTP
# =============================================================


# -------------------------------------------------------------
# 1. CLAVE SSH
# -------------------------------------------------------------
# Generamos un par de claves SSH automáticamente.
# -------------------------------------------------------------
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Guardamos la clave privada en un fichero local
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/private_key.pem"
  file_permission = "0600"  # Solo el propietario puede leerla (requerido por SSH)
}


# -------------------------------------------------------------
# 2. RED VIRTUAL (VNet)
# -------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-casopractico2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = var.environment
  }
}


# -------------------------------------------------------------
# 3. SUBRED (Subnet)
# -------------------------------------------------------------
# División dentro de la VNet donde vivirá la VM.
# -------------------------------------------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-casopractico2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name  # Referencia a la VNet anterior
  address_prefixes     = ["10.0.1.0/24"]
}


# -------------------------------------------------------------
# 4. NETWORK SECURITY GROUP (NSG) + REGLAS
# -------------------------------------------------------------
# Es el firewall de la VM. Por defecto Azure bloquea TODO.
# Abrimos explícitamente solo los puertos que necesitamos:
#   - Puerto 22: SSH (para conectarnos desde el WSL)
#   - Puerto 80: HTTP (para acceder al servidor web NGINX)
# -------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-casopractico2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # Regla para SSH - permite conectarnos a la VM desde cualquier IP
  security_rule {
    name                       = "SSH"
    priority                   = 100        # Menor número = mayor prioridad
    direction                  = "Inbound"  # Tráfico entrante
    access                     = "Allow"    # Permitir
    protocol                   = "Tcp"
    source_port_range          = "*"        # Cualquier puerto origen
    destination_port_range     = "22"       # Puerto SSH
    source_address_prefix      = "*"        # Desde cualquier IP
    destination_address_prefix = "*"        # Hacia cualquier IP de la VM
  }

  # Regla para HTTP - permite acceder al servidor web NGINX
  security_rule {
    name                       = "HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"       # Puerto HTTP
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}


# -------------------------------------------------------------
# 5. IP PÚBLICA
# -------------------------------------------------------------
# Dirección IP accesible desde internet.
# Sin ella la VM sería invisible desde fuera de Azure.
# La ponemos como "Static" para que no cambie al reiniciar la VM.
# -------------------------------------------------------------
resource "azurerm_public_ip" "vm_pip" {
  name                = "pip-casopractico2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"  # IP fija, no cambia al reiniciar

  tags = {
    environment = var.environment
  }
}


# -------------------------------------------------------------
# 6. NETWORK INTERFACE (NIC)
# -------------------------------------------------------------
# Es la tarjeta de red virtual de la VM.
# Une la VM con la Subnet y la IP Pública.
# Sin ella la VM no tiene conectividad de red.
# -------------------------------------------------------------
resource "azurerm_network_interface" "nic" {
  name                = "nic-casopractico2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id           # Conecta a la subnet
    private_ip_address_allocation = "Dynamic"                          # IP privada automática
    public_ip_address_id          = azurerm_public_ip.vm_pip.id        # Conecta la IP pública
  }

  tags = {
    environment = var.environment
  }
}


# -------------------------------------------------------------
# 7. ASOCIACIÓN NIC → NSG
# -------------------------------------------------------------
# El NSG y la NIC son recursos independientes.
# Este recurso es el "pegamento" que los une,
# aplicando las reglas de seguridad a la interfaz de red.
# -------------------------------------------------------------
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


# -------------------------------------------------------------
# 8. LA MÁQUINA VIRTUAL
# -------------------------------------------------------------
# Finalmente la VM en sí, que usa todo lo definido anteriormente.
# Ubuntu 22.04 LTS con acceso por SSH mediante clave.
# -------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-casopractico2"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size        
  admin_username        = var.admin_username 

  # Conectamos la VM a la NIC que hemos creado
  network_interface_ids = [azurerm_network_interface.nic.id]

  # Clave SSH para acceder a la VM
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  # Disco del sistema operativo
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Imagen del sistema operativo: Ubuntu 22.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }
}
