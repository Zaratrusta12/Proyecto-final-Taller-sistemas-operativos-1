# Plan de direccionamiento IP — Laboratorio Mabe

## Parámetros de red

| Parámetro | Valor |
|-----------|--------|
| Red LAN | `192.168.10.0/24` |
| Máscara | `255.255.255.0` |
| Gateway (documentado) | `192.168.10.1` |
| Dominio DNS | `mabe.tso1` |
| Red VirtualBox | Internal Network: `intnet-mabe` |

> Nota: en red 100% interna sin router real, el gateway puede quedar configurado igual para cumplir la opción DHCP. La comunicación entre VMs no depende del gateway.

## Asignación estática

| Equipo | Hostname | IP | DNS | Función |
|--------|----------|-----|-----|---------|
| Controlador de dominio | `SRV-DC01` | `192.168.10.10` | `127.0.0.1` (luego `192.168.10.10`) | AD DS, DNS, DHCP, GPO |
| Servidor de aplicaciones | `SRV-APP01` | `192.168.10.20` | `192.168.10.10` | IIS, archivos, impresión, correo |
| Impresora lógica Recepción | `IMP-REC` | `192.168.10.30` | — | Documentación / cola |
| Impresora lógica Laboratorio | `IMP-LAB` | `192.168.10.31` | — | Documentación / cola |
| Impresora lógica Administración | `IMP-ADM` | `192.168.10.32` | — | Documentación / cola |

Las impresoras pueden implementarse como colas con driver genérico/PDF sin dispositivo físico. Las IPs `.30-.32` son referenciales para el diagrama.

## DHCP

| Parámetro | Valor |
|-----------|--------|
| Scope name | `LAN-Mabe` |
| Scope network | `192.168.10.0` |
| Rango de distribución | `192.168.10.100` – `192.168.10.200` |
| **Rango de exclusión** | **`192.168.10.1` – `192.168.10.50`** |
| Duración de lease | 8 días (ajustable) |
| Opción 003 Router | `192.168.10.1` |
| Opción 006 DNS Servers | `192.168.10.10` |
| Opción 015 DNS Domain Name | `mabe.tso1` |

## Cliente de pruebas

| Equipo | Hostname | IP | Unión a dominio |
|--------|----------|-----|-----------------|
| Estación recepción | `PC-REC01` | Por DHCP (esperada en `.100-.200`) | `mabe.tso1` |

## Reglas rápidas

1. Todo servidor: IP estática fuera del pool (dentro de la exclusión `.1-.50`).
2. Todo cliente de usuario: DHCP.
3. DNS de miembros del dominio: siempre `192.168.10.10` (nunca 8.8.8.8 como primario en el lab interno).
4. Antes de unir al dominio: verificar `ping 192.168.10.10` y `nslookup mabe.tso1`.
