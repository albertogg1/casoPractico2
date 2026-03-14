# Caso Práctico 2

## Alberto García
## EU DevOps & Cloud - UNIR

Este proyecto implementa una infraestructura en la nube utilizando Terraform y Ansible para desplegar y configurar recursos como Azure Container Registry (ACR), Azure Kubernetes Service (AKS) y máquinas virtuales (VM).

## Estructura del proyecto

- **terraform/**: Archivos de configuración de Terraform para crear los recursos en Azure.
- **ansible/**: Playbooks y roles de Ansible para la configuración y provisión de los recursos creados.
- **deploy.sh**: Script para automatizar el despliegue.

## Requisitos previos
- Tener instalado [Terraform](https://www.terraform.io/)
- Tener instalado [Ansible](https://www.ansible.com/)
- Acceso a una suscripción de Azure

## Despliegue

1. **Inicializar y aplicar Terraform:**
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```
2. **Configurar recursos con Ansible:**
   ```bash
   cd ../ansible
   ansible-playbook -i hosts playbook.yml
   ```
3. **Automatización:**
   También puedes usar el script `deploy.sh` para automatizar el proceso completo.

## Limpieza
Para destruir la infraestructura creada:
```bash
cd terraform
terraform destroy
```
