# Checklist Día 1 — VirtualBox + instalación SO

Usar cuando ya tengan las ISO de **Windows Server 2025 Standard** (Desktop Experience) y del cliente.

## A. Preparar VirtualBox

- [ ] VirtualBox instalado + Extension Pack
- [ ] Espacio libre ≥ 150 GB
- [ ] Crear red: **File → Tools → Network Manager → Host-only / o usar Internal Network**
- [ ] Nombre de red interna en cada VM: `intnet-mabe`
- [ ] (Opcional) Segundo adaptador NAT solo para actualizaciones

## B. Crear VM SRV-DC01

| Recurso | Valor |
|---------|--------|
| Name | SRV-DC01 |
| Type | Microsoft Windows |
| Version | Other Windows (64-bit) / Server 2022 si no aparece 2025 |
| RAM | 4096–6144 MB |
| CPUs | 2 |
| Disk | VDI dinámico 60 GB |
| Network Adapter 1 | Internal Network, name `intnet-mabe` |
| Nested VT-x | Enabled (si luego usan Hyper-V aquí) |

- [ ] Montar ISO WS2025 e instalar **Standard con Experiencia de Escritorio**
- [ ] Password local admin de lab (ej. `Mabe#Lab2025`)
- [ ] Completar OOBE / escritorio
- [ ] **Capturas** en `02_Implementacion/capturas/01_instalacion/`

### Post-instalación DC01 (antes de AD)

```powershell
Rename-Computer -NewName 'SRV-DC01' -Restart
```

Después del reinicio, IP estática:

```powershell
# Ajustar el nombre del interfaz si no es Ethernet
Get-NetAdapter
New-NetIPAddress -InterfaceAlias 'Ethernet' -IPAddress '192.168.10.10' -PrefixLength 24 -DefaultGateway '192.168.10.1'
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses '127.0.0.1'
```

- [ ] Hostname `SRV-DC01`
- [ ] IP `192.168.10.10`
- [ ] Snapshot `00_SO_limpio`

## C. Crear VM SRV-APP01

Igual que arriba, disco 80 GB recomendado.

```powershell
Rename-Computer -NewName 'SRV-APP01' -Restart
```

```powershell
New-NetIPAddress -InterfaceAlias 'Ethernet' -IPAddress '192.168.10.20' -PrefixLength 24 -DefaultGateway '192.168.10.1'
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses '192.168.10.10'
```

- [ ] `ping 192.168.10.10` responde cuando DC01 esté arriba
- [ ] Snapshot `00_SO_limpio`
- [ ] **Aún NO unir al dominio** (falta promover AD)

## D. Crear VM PC-REC01

| Recurso | Valor |
|---------|--------|
| RAM | 2048–4096 MB |
| Disk | 40–50 GB |
| Network | Internal `intnet-mabe` |

- [ ] Instalar Windows 10/11
- [ ] Hostname `PC-REC01`
- [ ] Por ahora IP manual temporal `.50` o esperar DHCP
- [ ] Snapshot `00_SO_limpio`

## E. Al terminar el día 1 deben tener

- [ ] 3 VMs instaladas
- [ ] DC01 y APP01 con IP correcta
- [ ] Ping entre DC01 y APP01 OK
- [ ] Capturas de instalación y de `ipconfig` / configuración IP
- [ ] Topología empezada en draw.io (puede quedar al 80%)

## Siguiente (Día 2)

1. En DC01: agregar rol **AD DS** + promover dominio `mabe.tso1`
2. DNS
3. DHCP + exclusión
4. Scripts `crear_ou_grupos.ps1` y `crear_usuarios.ps1`
5. Unir APP01 y PC-REC01 al dominio
