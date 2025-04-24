# Configuración de Terraform para ELK Stack en Hetzner Cloud

# Proveedor Hetzner Cloud
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.44.1"
    }
  }
}

# Configura el proveedor con tu token de API
provider "hcloud" {
  token = var.hcloud_token
}

# Variables
variable "hcloud_token" {
  type        = string
  description = "Token de API de Hetzner Cloud"
  sensitive   = true  # Marca como sensible para que no aparezca en logs
}

variable "server_type" {
  type        = string
  description = "Tipo de servidor para ELK Stack"
  default     = "cpx51"  # 16 vCPUs, 32 GB RAM - ajustar según necesidades
}

variable "os_type" {
  type        = string
  description = "Sistema operativo para los servidores"
  default     = "ubuntu-22.04"
}

variable "location" {
  type        = string
  description = "Ubicación del datacenter"
  default     = "nbg1"  # Nuremberg, Alemania
}

variable "elk_server_count" {
  type        = number
  description = "Número de servidores para el cluster ELK"
  default     = 1  # Para desarrollo, 1 es suficiente
}

# Llave SSH para acceso a los servidores
resource "hcloud_ssh_key" "elk_key" {
  name       = "elk-ssh-key"
  public_key = file("${path.module}/ssh/elk_rsa.pub")
}

# Red privada para comunicación interna
resource "hcloud_network" "elk_network" {
  name     = "elk-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "elk_subnet" {
  network_id   = hcloud_network.elk_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Servidor principal para ELK Stack
resource "hcloud_server" "elk_server" {
  count       = var.elk_server_count
  name        = "elk-server-${count.index + 1}"
  server_type = var.server_type
  image       = var.os_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.elk_key.id]

  # Script de usuario para configuración inicial
  user_data = <<-EOF
    #!/bin/bash
    # Actualizar paquetes
    apt-get update
    apt-get upgrade -y

    # Instalar Docker y Docker Compose
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Configurar límites para Elasticsearch
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    sysctl -p

    # Crear directorio para ELK Stack
    mkdir -p /opt/elk-stack
  EOF

  # Conectar a la red privada
  network {
    network_id = hcloud_network.elk_network.id
    ip         = "10.0.1.${count.index + 10}"
  }

  # Esperar a que el servidor esté listo
  provisioner "remote-exec" {
    inline = ["echo 'Servidor listo!'"]  

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("${path.module}/ssh/elk_rsa")
      host        = self.ipv4_address
    }
  }
}

# Volumen para datos de Elasticsearch
resource "hcloud_volume" "elk_data" {
  count     = var.elk_server_count
  name      = "elk-data-${count.index + 1}"
  size      = 100  # GB - ajustar según necesidades
  server_id = hcloud_server.elk_server[count.index].id
  automount = true
  format    = "ext4"
}

# Firewall para proteger los servidores
resource "hcloud_firewall" "elk_firewall" {
  name = "elk-firewall"

  # Regla para SSH
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0"]  # Opcional: restringir a tu IP
  }

  # Regla para Kibana
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "5601"
    source_ips = ["0.0.0.0/0"]  # Opcional: restringir a tus IPs
  }

  # Regla para Elasticsearch API
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "9200"
    source_ips = ["0.0.0.0/0"]  # Restringir a IPs específicas en producción
  }

  # Regla para Logstash Beats input
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "5044"
    source_ips = ["0.0.0.0/0"]  # Restringir a tus IPs de servidores
  }

  # Aplicar a todos los servidores ELK
  apply_to {
    server = hcloud_server.elk_server[*].id
  }
}

# Salida de información importante
output "elk_server_ips" {
  value = {
    for idx, server in hcloud_server.elk_server : "elk-server-${idx + 1}" => {
      public_ip  = server.ipv4_address
      private_ip = server.network[0].ip
    }
  }
}

output "kibana_url" {
  value = "http://${hcloud_server.elk_server[0].ipv4_address}:5601"
}
