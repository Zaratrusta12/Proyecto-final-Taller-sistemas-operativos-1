# Checklist Día 1 — VirtualBox + instalación SO (4 sucursales)

**Precondiciones:**
- [ ] ISOs de Windows Server 2025 Standard Desktop + Windows 10/11
- [ ] VirtualBox + Extension Pack instalados
- [ ] Espacio libre >= 200 GB (2 servers + 4 clientes)
- [ ] RAM >= 16 GB

**Contraseñas lab:**
- Admin (local/dominio): `Mabe#Lab2025`
- Usuarios de dominio: `User#Lab`

**Capturas:** `02_Implementacion/capturas/01_instalacion/`

---

## A. Preparar VirtualBox: 4 redes internas

1. Abrir VirtualBox
2. Para cada VM que creemos, el adaptador se asigna a una de estas 4 redes internas:

| Red interna | Sucursal | Subred |
|-------------|----------|--------|
| `intnet-mabe-central` | Central | 192.168.10.0/24 |
| `intnet-mabe-norte` | Norte | 192.168.20.0/24 |
| `intnet-mabe-este` | Este | 192.168.30.0/24 |
| `intnet-mabe-sur` | Sur | 192.168.40.0/24 |

> No hay que "crear" las redes en VirtualBox antes. Se crean al asignarles el nombre en el adaptador de una VM.

---

## B. Crear VM SRV-DC01 (4 NICs)

| Recurso | Valor |
|---------|--------|
| Name | SRV-DC01 |
| RAM | 4096-6144 MB |
| CPUs | 2 |
| Disk | VDI dinámico 60 GB |
| Adapter 1 | Internal Network, `intnet-mabe-central` |
| Adapter 2 | Internal Network, `intnet-mabe-norte` |
| Adapter 3 | Internal Network, `intnet-mabe-este` |
| Adapter 4 | Internal Network, `intnet-mabe-sur` |
| Nested VT-x | Enabled (para Hyper-V despues) |

- [ ] Crear VM con 4 adaptadores
- [ ] Montar ISO WS2025 e instalar **Standard con Experiencia de Escritorio**
- [ ] Password local admin: `Mabe#Lab2025`
- [ ] Completar OOBE
- [ ] **Capturas** del proceso de instalacion

### Post-instalacion DC01 (antes de AD)

1. Cambiar hostname:
   - Settings → System → About → Rename this PC
   - O PowerShell: `Rename-Computer -NewName 'SRV-DC01' -Restart`

2. Configurar las 4 IPs estaticas por GUI:
   - Settings → Network & Internet → Ethernet → cada adaptador
   - O abrir `ncpa.cpl` (Network Connections)
   - Click derecho en cada adaptador → Properties → IPv4 → Properties

| Adaptador | IP | Máscara | Gateway | DNS |
|-----------|----|---------|---------|-----|
| Ethernet (Central) | 192.168.10.10 | 255.255.255.0 | (vacío) | 127.0.0.1 |
| Ethernet 2 (Norte) | 192.168.20.10 | 255.255.255.0 | (vacío) | 127.0.0.1 |
| Ethernet 3 (Este) | 192.168.30.10 | 255.255.255.0 | (vacío) | 127.0.0.1 |
| Ethernet 4 (Sur) | 192.168.40.10 | 255.255.255.0 | (vacío) | 127.0.0.1 |

> El DC no necesita gateway: el es el gateway de cada subred.
> DNS en 127.0.0.1 por ahora (apuntar a si mismo, que sera el DNS).

- [ ] 4 IPs configuradas
- [ ] `ipconfig /all` muestra las 4 IPs
- [ ] Snapshot `00_SO_limpio`

---

## C. Crear VM SRV-APP01 (1 NIC)

| Recurso | Valor |
|---------|--------|
| Name | SRV-APP01 |
| RAM | 4096 MB |
| CPUs | 2 |
| Disk | VDI dinámico 80 GB |
| Adapter 1 | Internal Network, `intnet-mabe-central` |

- [ ] Montar ISO WS2025 e instalar Standard Desktop
- [ ] Password local admin: `Mabe#Lab2025`
- [ ] Cambiar hostname a `SRV-APP01`
- [ ] Configurar IP por GUI (`ncpa.cpl`):

| IP | Máscara | Gateway | DNS |
|----|---------|---------|-----|
| 192.168.10.20 | 255.255.255.0 | 192.168.10.10 | 192.168.10.10 |

> Gateway = DC central (para que el DC enrute hacia las sucursales)
> DNS = DC central

- [ ] `ping 192.168.10.10` responde (cuando DC01 esté arriba)
- [ ] Snapshot `00_SO_limpio`
- [ ] **Aún NO unir al dominio** (falta promover AD)

---

## D. Crear 4 VMs cliente (1 por sucursal)

### Opcion rapida: instalar 1 y clonar 3 (linked clones)

1. Crear PC-REC01 (Central):
   - Windows 10/11 Pro, RAM 2048-4096 MB, disco 40 GB
   - Adapter 1: `intnet-mabe-central`
   - Hostname `PC-REC01`
   - DHCP por ahora (sin IP fija)
   - Snapshot `00_SO_limpio`

2. Clonar PC-REC01 tres veces (linked clone):
   - VirtualBox → click derecho PC-001 → Clone
   - Name: PC-NORTE01, PC-ESTE01, PC-SUR01
   - Clone type: Linked clone
   - En cada clon, cambiar el adaptador a su red interna:
     - PC-NORTE01 → `intnet-mabe-norte`
     - PC-ESTE01 → `intnet-mabe-este`
     - PC-SUR01 → `intnet-mabe-sur`

3. En cada clon, cambiar hostname:
   - Settings → System → About → Rename this PC
   - PC-NORTE01, PC-ESTE01, PC-SUR01

- [ ] PC-REC01 creado y snapshot
- [ ] PC-NORTE01 clonado, red cambiada, hostname cambiado
- [ ] PC-ESTE01 clonado, red cambiada, hostname cambiado
- [ ] PC-SUR01 clonado, red cambiada, hostname cambiado

---

## E. Al terminar el Día 1 deben tener

- [ ] 6 VMs creadas (2 servers + 4 clientes)
- [ ] SRV-DC01 con 4 NICs y 4 IPs estaticas
- [ ] SRV-APP01 con 1 NIC e IP .20
- [ ] 4 clientes, cada uno en su red interna
- [ ] Ping DC01 ↔ APP01 OK
- [ ] Capturas de instalacion e `ipconfig`
- [ ] Topología actualizada en draw.io (4 sucursales)
- [ ] Snapshots `00_SO_limpio` en todas

---

## Siguiente (Día 2)

1. En DC01: agregar rol **AD DS** + promover dominio `mabe.tso1`
2. DNS + 4 scopes DHCP (uno por sucursal)
3. RRAS LAN routing en el DC
4. AD Sites + Subnets (4 sitios)
5. Scripts `crear_ou_grupos.ps1` y `crear_usuarios.ps1`
6. Unir APP01 y los 4 clientes al dominio
