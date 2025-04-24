# Terraform para ELK Stack en Hetzner Cloud

Este directorio contiene configuraciones de Terraform para aprovisionar infraestructura para ELK Stack en Hetzner Cloud, específicamente optimizada para el servidor EPYC 9454p.

## Estructura de Archivos

```
terraform/
├── main.tf                 # Configuración principal de Terraform
├── variables.tf            # Variables adicionales (opcional)
├── outputs.tf              # Outputs adicionales (opcional)
└── ssh/                    # Directorio para llaves SSH (incluir en .gitignore)
    ├── elk_rsa             # Llave privada SSH (no incluir en control de versiones)
    └── elk_rsa.pub         # Llave pública SSH
```

## Requisitos Previos

1. **Terraform** instalado (versión 1.0+)
2. **Cuenta en Hetzner Cloud** con un token de API generado
3. **Par de llaves SSH** para acceso a los servidores:
   ```bash
   # Generar llaves SSH si no existen
   mkdir -p ssh
   ssh-keygen -t rsa -b 4096 -f ssh/elk_rsa
   ```

## Configuración

1. **Crear un archivo de variables**:
   Crea un archivo `terraform.tfvars` (incluido en .gitignore) con las siguientes variables:
   ```hcl
   hcloud_token = "tu_token_api_de_hetzner"
   ```

2. **Personalizar configuración**:
   Ajusta en `main.tf` los siguientes parámetros según necesites:
   - `server_type`: Tipo de servidor en Hetzner (por defecto "cpx51")
   - `location`: Ubicación del datacenter (por defecto "nbg1" - Nuremberg)
   - `elk_server_count`: Número de servidores para el cluster
   - Tamaño del volumen para datos de Elasticsearch

## Uso

1. **Inicializar Terraform**:
   ```bash
   terraform init
   ```

2. **Ver plan de ejecución**:
   ```bash
   terraform plan
   ```

3. **Aplicar la configuración**:
   ```bash
   terraform apply
   ```

4. **Obtener información de salida**:
   ```bash
   terraform output
   ```

5. **Eliminar infraestructura** (cuando ya no sea necesaria):
   ```bash
   terraform destroy
   ```

## Configuración Post-Aprovisionamiento

Una vez que los servidores están aprovisionados, necesitarás:

1. **Copiar archivos de configuración de ELK Stack**:
   ```bash
   # Usar la dirección IP de salida de terraform output
   scp -i ssh/elk_rsa -r ../implementation/* root@<IP_DEL_SERVIDOR>:/opt/elk-stack/
   ```

2. **Iniciar los servicios de ELK Stack**:
   ```bash
   ssh -i ssh/elk_rsa root@<IP_DEL_SERVIDOR> "cd /opt/elk-stack && docker-compose up -d"
   ```

## Consideraciones para Producción

1. **Alta Disponibilidad**:
   - Aumenta `elk_server_count` a 3 o más para cluster de Alta Disponibilidad
   - Configura un balanceador de carga para Kibana

2. **Seguridad**:
   - Restringe las reglas del firewall a IPs específicas
   - Configura HTTPS para Kibana y Elasticsearch
   - Usa contraseñas seguras y certificados SSL personalizados

3. **Respaldos**:
   - Configura snapshots de Elasticsearch a un almacenamiento externo
   - Considera habilitar respaldos automáticos de Hetzner

4. **Monitoreo**:
   - Configura monitoreo y alertas para los propios servidores ELK
   - Considera implementar un segundo sistema para monitorear la salud de tu stack ELK

## Solución de Problemas

1. **Error de API Hetzner**:
   Verifica que tu token tenga los permisos correctos y no haya expirado.

2. **Problemas de conexión SSH**:
   Asegúrate de que las llaves SSH estén correctamente generadas y ubicadas en el directorio `ssh/`.

3. **Insuficientes recursos**:
   Si recibes errores sobre límites de recursos, puede ser necesario solicitar un aumento de cuota en tu cuenta de Hetzner.

## Referencias

- [Documentación oficial de Terraform](https://www.terraform.io/docs/cli/index.html)
- [Proveedor de Hetzner Cloud para Terraform](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- [Documentación de Hetzner Cloud](https://docs.hetzner.com/cloud/)