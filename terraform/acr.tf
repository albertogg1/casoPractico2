# =============================================================
# acr.tf - Azure Container Registry
# =============================================================
# Registro privado de imágenes de contenedores.
# Es el repositorio donde guardaremos las imágenes que
# usarán tanto la VM (NGINX) como el AKS 
# =============================================================

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku = "Basic"
  admin_enabled = true  # Para facilitar

  tags = {
    environment = var.environment
  }
}