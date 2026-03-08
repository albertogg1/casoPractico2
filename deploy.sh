#!/bin/bash
# =============================================================
# deploy.sh - Despliegue completo de la infraestructura
# =============================================================
# Ejecuta Terraform y Ansible de forma secuencial
# Uso: ./deploy.sh
# =============================================================

set -e  # Para si hay algún error

echo "=================================================="
echo "🚀 Iniciando despliegue de casoPractico2"
echo "=================================================="

# -------------------------------------------------------------
# 1. TERRAFORM
# -------------------------------------------------------------
echo ""
echo "📦 Creando infraestructura con Terraform..."
cd "$(dirname "$0")/terraform"

terraform init -input=false
terraform apply -auto-approve

# -------------------------------------------------------------
# 2. OBTENER OUTPUTS DE TERRAFORM
# -------------------------------------------------------------
echo ""
echo "📝 Obteniendo outputs de Terraform..."

VM_IP=$(terraform output -raw vm_public_ip)
ACR_SERVER=$(terraform output -raw acr_login_server)
ACR_USER=$(terraform output -raw acr_admin_username)
ACR_PASS=$(terraform output -raw acr_admin_password)

echo "✅ VM IP: $VM_IP"
echo "✅ ACR: $ACR_SERVER"

# -------------------------------------------------------------
# 3. GENERAR SECRETS.YML
# -------------------------------------------------------------
echo ""
echo "🔐 Generando secrets.yml..."
cat > ../ansible/secrets.yml << EOF
acr_login_server: "${ACR_SERVER}"
acr_username: "${ACR_USER}"
acr_password: "${ACR_PASS}"
EOF
echo "✅ secrets.yml generado"

# -------------------------------------------------------------
# 4. ACTUALIZAR HOSTS
# -------------------------------------------------------------
echo ""
echo "📋 Actualizando inventario de Ansible..."
cat > ../ansible/hosts << EOF
[vm]
${VM_IP} ansible_user=azureuser ansible_ssh_private_key_file=../terraform/private_key.pem

[acr]
localhost ansible_connection=local

[localhost]
localhost ansible_connection=local
EOF
echo "✅ hosts actualizado con IP: $VM_IP"

# -------------------------------------------------------------
# 5. ANSIBLE
# -------------------------------------------------------------
echo ""
echo "⚙️  Ejecutando Ansible..."
cd ../ansible

# Esperar a que la VM esté lista para SSH
echo "⏳ Esperando a que la VM esté lista..."
sleep 30

ansible-playbook -i hosts playbook.yml

# Obtener IP de la app de votación
echo "⏳ Esperando IP de la app de votación..."
VOTE_IP=""
RETRIES=20
while [ -z "$VOTE_IP" ] && [ $RETRIES -gt 0 ]; do
  VOTE_IP=$(kubectl get service azure-vote-front -n casopractico2 \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  if [ -z "$VOTE_IP" ]; then
    sleep 15
    RETRIES=$((RETRIES-1))
  fi
done

# -------------------------------------------------------------
# 6. RESUMEN FINAL
# -------------------------------------------------------------
echo ""
echo "=================================================="
echo "✅ Despliegue completado"
echo "=================================================="
echo ""
echo "🌐 Servidor NGINX:     http://${VM_IP}"
echo "📦 ACR:                ${ACR_SERVER}"
echo "🗳️  App de votación:   http://${VOTE_IP}"
echo ""
echo "Para obtener la IP de la app de votación:"
echo "kubectl get services -n casopractico2"
echo ""
echo "Para destruir la infraestructura:"
echo "cd terraform && terraform destroy"
echo "=================================================="
```