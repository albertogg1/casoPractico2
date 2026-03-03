# =============================================================
# AKS - Azure Kubernetes Service
# =============================================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${var.environment}"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = {
    environment = var.environment
  }
}

// Conceder al AKS (identidad administrada) el permiso AcrPull sobre el ACR
data "azurerm_role_definition" "acrpull" {
  name  = "AcrPull"
  scope = azurerm_container_registry.acr.id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope              = azurerm_container_registry.acr.id
  role_definition_id = data.azurerm_role_definition.acrpull.id
  principal_id       = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}
