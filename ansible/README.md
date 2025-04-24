# Ansible para ELK Stack en entorno Fintech

Este directorio contiene los playbooks y configuraciones de Ansible para desplegar y configurar agentes de monitoreo ELK en los servidores Windows.

## Estructura de Archivos

```
ansible/
├── inventory.ini             # Inventario de servidores
├── playbook.yml              # Playbook principal
├── roles/                    # Roles específicos (opcional)
└── files/                    # Archivos de configuración para los agentes
    ├── filebeat-windows.yml  # Config para Filebeat general
    ├── filebeat-iis.yml      # Config para Filebeat en IIS
    ├── metricbeat-sql-server.yml  # Config para SQL Server
    ├── metricbeat-netcore-iis.yml # Config para IIS/.NET Core
    └── metricbeat-nodejs-pm2.yml  # Config para Node.js/PM2
```

## Requisitos Previos

1. **Ansible** instalado en la máquina de control (preferiblemente Linux/WSL)
2. **pywinrm** para conexiones WinRM a servidores Windows:
   ```bash
   pip install pywinrm
   ```
3. **WinRM habilitado** en todos los servidores Windows:
   ```powershell
   # Ejecutar en PowerShell como Administrador en cada servidor Windows
   winrm quickconfig
   winrm set winrm/config/service/auth '@{Basic="true"}'
   winrm set winrm/config/service '@{AllowUnencrypted="true"}'
   # Nota: Para producción, configurar con HTTPS en lugar de permitir sin cifrado
   ```

## Instrucciones de Uso

1. **Actualiza el inventario**:
   Edita `inventory.ini` para incluir todos tus servidores con sus direcciones IP correctas.

2. **Prepara los archivos de configuración**:
   Copia los archivos de configuración de ELK desde el directorio de implementación a la carpeta `files/`.

3. **Personaliza las variables**:
   Ajusta las direcciones IP, credenciales y otras configuraciones específicas en los archivos de configuración.

4. **Ejecuta el playbook**:
   ```bash
   ansible-playbook -i inventory.ini playbook.yml
   ```

5. **Verifica la instalación**:
   Comprueba que los servicios estén ejecutándose en todos los servidores.

## Personalización Adicional

### Variables Específicas para Entornos

Puedes crear archivos de variables para diferentes entornos:

```
group_vars/
├── development.yml
├── production.yml
└── testing.yml
```

### Roles Avanzados

Para una configuración más modular, puedes dividir las tareas en roles:

```
roles/
├── common/
├── filebeat/
├── metricbeat/
└── apm/
```

## Solución de Problemas

### Problemas Comunes de WinRM

1. **Error de conexión**:
   Verifica que WinRM esté habilitado y configurado correctamente:
   ```powershell
   Test-WSMan
   ```

2. **Errores de autenticación**:
   Asegúrate de que las credenciales sean correctas y que el usuario tenga permisos de administrador.

3. **Problemas de doble salto**:
   Si necesitas conectarte desde un servidor a otro, considera usar CredSSP:
   ```powershell
   Enable-WSManCredSSP -Role Server -Force
   ```

### Verificación Manual de Servicios

Para verificar manualmente los servicios en Windows:
```powershell
Get-Service filebeat, metricbeat
```

## Referencias

- [Documentación oficial de Ansible para Windows](https://docs.ansible.com/ansible/latest/user_guide/windows_usage.html)
- [Guía de WinRM para Ansible](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html)