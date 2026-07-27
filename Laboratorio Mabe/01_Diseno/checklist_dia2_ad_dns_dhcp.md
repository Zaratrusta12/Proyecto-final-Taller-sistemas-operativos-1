# Checklist Día 2 — SERVER1: AD DS + DNS + DHCP + UO/Users

**Precondiciones (ya cumplidas):**
- [x] 3 VMs instaladas
- [x] Ping entre SRV-DC01 (`.10`) y SRV-APP01 (`.20`)
- [x] Contraseñas: Admin `Admin#Lab2025` | Users `User#Lab`

**Capturas:** guardar en `02_Implementacion/capturas/02_ad_dns_dhcp/` y `03_ou_usuarios_gpo/`

**Dominio exacto a escribir:** `mabe.tso1`  
(con punto: `mabe` + `.` + `tso1`)

---

## 0. Antes de tocar AD (2 min)

En **SRV-DC01**, PowerShell como Administrador:

```powershell
hostname
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like '192.168.*'} | Format-Table
Get-DnsClientServerAddress -AddressFamily IPv4
```

Verificar:
- Hostname = `SRV-DC01`
- IP = `192.168.10.10`
- DNS preferido = `127.0.0.1` o `192.168.10.10`

Snapshot VirtualBox recomendado: `00_SO_limpio` (si no lo tienen).

---

## 1. Instalar rol AD DS

### Opción A — GUI (recomendada para capturas)

1. **Server Manager** → **Add roles and features**
2. Installation type: **Role-based or feature-based**
3. Server: **SRV-DC01**
4. Roles: marcar **Active Directory Domain Services**
5. Add Features → Next → Next → **Install**
6. Esperar a que termine (no reinicia solo todavía)
7. **Captura:** wizard de instalación completado

### Opción B — PowerShell

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

---

## 2. Promover a Controlador de Dominio

### GUI

1. En Server Manager, bandera amarilla → **Promote this server to a domain controller**
2. Deployment Configuration:
   - **Add a new forest**
   - Root domain name: **`mabe.tso1`**
3. Domain Controller Options:
   - Forest/Domain functional level: **Windows Server 2025** (o el más alto disponible)
   - Marcar **Domain Name System (DNS) server**
   - Marcar **Global Catalog (GC)**
   - **NO** marcar RODC
   - DSRM password: `Admin#Lab2025`
4. DNS Options: si avisa delegación → **Next** (normal en lab)
5. NetBIOS: debe proponer **MABE** → Next
6. Paths: dejar default → Next
7. Review → **Install**
8. El servidor **reinicia solo**

**Capturas:**
- Pantalla "Add a new forest" con `mabe.tso1`
- Review Options
- Tras reinicio: login `MABE\Administrator` o `mabe.tso1\Administrator` con `Admin#Lab2025`

### PowerShell (alternativa)

```powershell
Install-ADDSForest `
  -DomainName 'mabe.tso1' `
  -DomainNetbiosName 'MABE' `
  -SafeModeAdministratorPassword (ConvertTo-SecureString 'Admin#Lab2025' -AsPlainText -Force) `
  -InstallDns `
  -Force
```

---

## 3. Verificación post-promoción (obligatoria)

Tras reinicio, login como Administrator del dominio. PowerShell:

```powershell
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DomainMode
Get-ADForest | Select-Object Name, ForestMode
Get-Service NTDS, DNS, ADWS | Format-Table Name, Status
whoami
```

Esperado:
- DNSRoot = `mabe.tso1`
- NetBIOS = `MABE`
- NTDS, DNS, ADWS = **Running**
- whoami ≈ `mabe\administrator`

Abrir **Active Directory Users and Computers** (`dsa.msc`) y capturar el dominio `mabe.tso1`.

Ajustar DNS del adaptador si hace falta:

```powershell
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses '192.168.10.10','127.0.0.1'
```

(El alias puede ser `Ethernet 2`, etc. Usar `Get-NetAdapter`.)

**Snapshot:** `01_AD_OK`

---

## 4. DNS — registros y prueba

Abrir **DNS Manager** (`dnsmgmt.msc`):

1. Forward Lookup Zones → **mabe.tso1**
2. Debe existir host **(same as parent)** y **SRV-DC01**
3. Crear registro A para APP01 (si aún no está en dominio):

```powershell
Add-DnsServerResourceRecordA -Name 'SRV-APP01' -ZoneName 'mabe.tso1' -IPv4Address '192.168.10.20'
```

Pruebas en DC01:

```powershell
nslookup mabe.tso1
nslookup srv-dc01.mabe.tso1
nslookup srv-app01.mabe.tso1
Resolve-DnsName mabe.tso1
```

**Capturas:** zona DNS + salida de nslookup.

---

## 5. DHCP con exclusión (requisito)

### 5.1 Instalar rol

```powershell
Install-WindowsFeature DHCP -IncludeManagementTools
```

O GUI: Add roles → **DHCP Server** → Install.

Post-install:
1. Server Manager → bandera → **Complete DHCP configuration**
2. Autorizar con cuenta Administrator del dominio → Commit

### 5.2 Crear scope (GUI — bueno para capturas)

1. Abrir **DHCP** (`dhcpmgmt.msc`)
2. Expandir SRV-DC01 → IPv4 → clic derecho → **New Scope**
3. Name: `LAN-Mabe`
4. Range:
   - Start: `192.168.10.100`
   - End: `192.168.10.200`
   - Mask: `255.255.255.0`
5. **Exclusions:**
   - Start: `192.168.10.1`
   - End: `192.168.10.50`
   - Add
6. Lease: 8 días (default OK)
7. Configure options: **Yes**
   - Router (Default Gateway): `192.168.10.1`
   - DNS Servers: `192.168.10.10` (quitar otros)
   - DNS Domain Name: `mabe.tso1`
8. Activate scope: **Yes**
9. Finish

### 5.3 Alternativa PowerShell completa

```powershell
Add-DhcpServerInDC -DnsName 'srv-dc01.mabe.tso1' -IPAddress '192.168.10.10'
Add-DhcpServerv4Scope -Name 'LAN-Mabe' -StartRange '192.168.10.100' -EndRange '192.168.10.200' -SubnetMask '255.255.255.0' -State Active
Add-DhcpServerv4ExclusionRange -ScopeId '192.168.10.0' -StartRange '192.168.10.1' -EndRange '192.168.10.50'
Set-DhcpServerv4OptionValue -ScopeId '192.168.10.0' -Router '192.168.10.1' -DnsServer '192.168.10.10' -DnsDomain 'mabe.tso1'
```

### 5.4 Verificar DHCP

```powershell
Get-DhcpServerv4Scope
Get-DhcpServerv4ExclusionRange -ScopeId '192.168.10.0'
Get-DhcpServerv4OptionValue -ScopeId '192.168.10.0'
```

**Capturas obligatorias:**
- Scope activo
- **Exclusion range 192.168.10.1 – 192.168.10.50**
- Opciones Router + DNS

---

## 6. UO, grupos y usuarios (scripts)

### 6.1 Copiar scripts al DC

Copiar desde el host a la VM (Shared Folder, drag&drop con Guest Additions, o USB):

- `05_Scripts/crear_ou_grupos.ps1`
- `05_Scripts/crear_usuarios.ps1`

Ejemplo si montan carpeta compartida `\\VBOXSVR\proyecto`:

```powershell
cd C:\Temp
# copiar scripts aquí
Set-ExecutionPolicy Bypass -Scope Process -Force
.\crear_ou_grupos.ps1
.\crear_usuarios.ps1
```

### 6.2 Verificar

```powershell
Get-ADOrganizationalUnit -Filter "Name -like 'UO_*'" | Select Name
Get-ADGroup -Filter "Name -like 'G_*'" | Select Name
# Miembros de un grupo (debe ser >= 5)
Get-ADGroupMember 'G_Rec_Usuarios' | Select Name, SamAccountName
```

Abrir **ADUC** (`dsa.msc`):
- Ver las 3 UO
- Expandir grupos y usuarios
- **Capturas** en `03_ou_usuarios_gpo/`

Password de los users creados: **`User#Lab`**

---

## 7. Unir SRV-APP01 al dominio

En **SRV-APP01** (PowerShell Admin):

```powershell
# DNS debe apuntar al DC
Get-DnsClientServerAddress -AddressFamily IPv4
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses '192.168.10.10'

Test-NetConnection 192.168.10.10 -Port 389
Resolve-DnsName mabe.tso1
ping mabe.tso1
```

Unir al dominio:

```powershell
Add-Computer -DomainName 'mabe.tso1' -Credential (Get-Credential) -Restart
```

En el popup de credenciales:
- Usuario: `mabe\Administrator` o `Administrator@mabe.tso1`
- Password: `Admin#Lab2025`

Tras reinicio, login: `MABE\Administrator`

Verificar:

```powershell
whoami
SystemInfo | findstr /B /C:"Domain"
```

**Captura:** System Properties mostrando Domain `mabe.tso1`

---

## 8. Unir PC-REC01 al dominio + prueba DHCP

En **PC-REC01**:

1. Configurar adaptador en **DHCP** (obtener IP automáticamente)
2. DNS también automático (lo da el DHCP) **o** fijar DNS `192.168.10.10` si aún no hay lease

```powershell
ipconfig /release
ipconfig /renew
ipconfig /all
```

Verificar en la salida:
- IP entre `192.168.10.100` y `.200`
- DHCP Habilitado: Sí
- Servidor DHCP: `192.168.10.10`
- Servidor DNS: `192.168.10.10`
- Sufijo: `mabe.tso1` (puede aparecer tras unir)

Unir al dominio (GUI o PowerShell):

```powershell
Add-Computer -DomainName 'mabe.tso1' -Credential (Get-Credential) -Restart
```

Tras reinicio, login de prueba:
- Usuario: `a.rojas` (o cualquier user del script)
- Password: `User#Lab`
- Cuenta: `MABE\a.rojas`

**Capturas:**
- `ipconfig /all` con IP del pool
- Login exitoso de usuario de dominio
- (Opcional) en DC: DHCP → Address Leases con el cliente

**Snapshot:** `02_DHCP_CLIENT_OK`

---

## 9. RDP básico en DC (admin)

En SRV-DC01:

```powershell
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'
```

O GUI: System Properties → Remote → Allow remote connections.

Probar desde PC-REC01 con `mstsc` → `192.168.10.10` → `MABE\Administrator`.

**Captura** en `08_rdp/`.

---

## 10. Cierre del Día 2 — checklist de aceptación

| # | Prueba | OK? |
|---|--------|-----|
| 1 | Dominio `mabe.tso1` existe | |
| 2 | DNS resuelve DC y APP | |
| 3 | DHCP scope activo | |
| 4 | Exclusión `.1-.50` visible | |
| 5 | 3 UO creadas | |
| 6 | 3 grupos por UO | |
| 7 | ≥5 usuarios por grupo | |
| 8 | APP01 en dominio | |
| 9 | PC-REC01 IP por DHCP del pool | |
| 10 | Login usuario dominio en cliente | |
| 11 | Capturas guardadas | |
| 12 | Snapshot `01_AD_OK` y `02_DHCP_CLIENT_OK` | |

### Aún NO (Día 2 noche o Día 3 mañana)
- 15 GPO (siguiente bloque)
- IIS, archivos, impresión, correo
- Hyper-V, backup

---

## Problemas frecuentes

| Síntoma | Causa probable | Solución |
|---------|----------------|----------|
| No encuentra dominio al unir | DNS del cliente/APP no es `.10` | Fijar DNS a `192.168.10.10` |
| nslookup falla | DNS no instalado / zona mal | Revisar rol DNS y servicio |
| DHCP no da IP | Scope inactivo o no autorizado | Complete DHCP config + Activate |
| Cliente IP `.10.x` rara / APIPA `169.254` | No llega al DHCP (red mal) | Verificar Internal Network `intnet-mabe` en las 3 VMs |
| Password User#Lab rechazada | Política de complejidad distinta | Usar `User#Lab1` si hiciera falta (tiene número) |
| No corre el script AD | No es DC aún / sin módulo | Promover primero; `Import-Module ActiveDirectory` |
| Alias Ethernet no existe | Nombre de NIC distinto | `Get-NetAdapter` y usar el Name real |

---

## Orden de trabajo en grupo (reparto sugerido)

| Integrante | Tarea |
|------------|-------|
| 1–2 | Promover AD + capturas en DC01 |
| 3 | DNS + DHCP + capturas |
| 4 | Correr scripts UO/users + capturas ADUC |
| 5 | Unir APP01 y PC-REC01 + pruebas ipconfig/login |

Al terminar este checklist, avisen **listo dia 2** y seguimos con **15 GPO** (puede ser el mismo día si hay tiempo) o **SERVER2**.
