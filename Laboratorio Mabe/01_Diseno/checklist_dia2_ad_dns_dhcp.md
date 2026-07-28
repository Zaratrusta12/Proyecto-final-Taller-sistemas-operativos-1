# Checklist Día 2 — SERVER1: AD DS + DNS + DHCP + RRAS + Sites (4 sucursales)

**Precondiciones (ya cumplidas):**
- [x] 6 VMs creadas (2 servers + 4 clientes)
- [x] SRV-DC01 con 4 NICs y 4 IPs estáticas
- [x] SRV-APP01 con 1 NIC e IP .20
- [x] Ping entre SRV-DC01 y SRV-APP01 OK
- [x] Contraseñas: Admin `Mabe#Lab2025` | Users `User#Lab`

**Capturas:** `02_Implementacion/capturas/02_ad_dns_dhcp/` y `03_ou_usuarios_gpo/`

**Dominio exacto a escribir:** `mabe.tso1` (con punto)

---

## 1. Instalar rol AD DS (GUI)

1. En SRV-DC01, abrir **Server Manager**
2. **Manage → Add Roles and Features**
3. Installation type: **Role-based or feature-based**
4. Server: **SRV-DC01**
5. Roles: marcar **Active Directory Domain Services**
6. Click **Add Features** → Next → Next → **Install**
7. Esperar a que termine (no reinicia todavía)
8. **Captura:** wizard de instalación completado

---

## 2. Promover a Controlador de Dominio (GUI)

1. En Server Manager, bandera amarilla (arriba derecha) → **Promote this server to a domain controller**
2. **Deployment Configuration:**
   - Seleccionar **Add a new forest**
   - Root domain name: **`mabe.tso1`**
3. **Domain Controller Options:**
   - Forest/Domain functional level: **Windows Server 2025** (o el más alto disponible)
   - Marcar **Domain Name System (DNS) server**
   - Marcar **Global Catalog (GC)**
   - **NO** marcar RODC
   - DSRM password: `Mabe#Lab2025`
4. **DNS Options:** si avisa delegación → **Next** (normal en lab)
5. **Additional Options** → NetBIOS: debe proponer **MABE** → Next
6. **Paths:** dejar default → Next
7. **Review Options** → revisar → Next
8. **Install**
9. El servidor **reinicia solo**

**Capturas obligatorias:**
- Pantalla "Add a new forest" con `mabe.tso1`
- Review Options
- Tras reinicio: login `MABE\Administrator` con `Mabe#Lab2025`

---

## 3. Verificación post-promoción

Tras reinicio, login como `MABE\Administrator`.

1. Abrir **Server Manager** → verificar que aparecen AD DS y DNS en roles instalados
2. Abrir **Active Directory Users and Computers** (`dsa.msc`):
   - Debe aparecer el dominio `mabe.tso1`
3. Abrir **DNS Manager** (`dnsmgmt.msc`):
   - Forward Lookup Zones → `mabe.tso1` debe existir
   - Debe haber registros de SRV-DC01

**Capturas:**
- Server Manager con roles
- ADUC con dominio `mabe.tso1`
- DNS Manager con zona

**Snapshot:** `01_AD_OK`

---

## 4. DNS — registros

1. Abrir **DNS Manager** (`dnsmgmt.msc`)
2. Expandir SRV-DC01 → Forward Lookup Zones → `mabe.tso1`
3. Verificar que exista el registro **SRV-DC01** (A)
4. Crear registro A para APP01:
   - Click derecho en la zona → **New Host (A)**
   - Name: `SRV-APP01`
   - IP: `192.168.10.20`
   - Marcar "Create associated pointer (PTR) record"
   - **Add Host**

Pruebas:
- Abrir CMD: `nslookup mabe.tso1`
- `nslookup srv-dc01.mabe.tso1`
- `nslookup srv-app01.mabe.tso1`

**Capturas:** zona DNS + salida de nslookup

---

## 5. DHCP — 4 scopes con exclusión (GUI)

### 5.1 Instalar rol DHCP

1. Server Manager → **Add Roles and Features**
2. Marcar **DHCP Server** → Add Features → Next → Install
3. Al terminar, bandera amarilla → **Complete DHCP configuration**
4. Usar credenciales de Administrator → Commit → Close

### 5.2 Crear 4 scopes (GUI — uno por sucursal)

Abrir **DHCP** (`dhcpmgmt.msc`). Expandir SRV-DC01 → IPv4.

**Para cada sucursal, click derecho IPv4 → New Scope:**

#### Scope 1: LAN-Central

| Campo | Valor |
|-------|-------|
| Name | LAN-Central |
| Start IP | 192.168.10.100 |
| End IP | 192.168.10.200 |
| Subnet mask | 255.255.255.0 |
| Exclusion Start | 192.168.10.1 |
| Exclusion End | 192.168.10.50 |
| Lease | 8 días (default) |
| Router (Gateway) | 192.168.10.10 |
| DNS Servers | 192.168.10.10 |
| DNS Domain Name | mabe.tso1 |
| Activate scope | Yes |

#### Scope 2: LAN-Norte

| Campo | Valor |
|-------|-------|
| Name | LAN-Norte |
| Start IP | 192.168.20.100 |
| End IP | 192.168.20.200 |
| Subnet mask | 255.255.255.0 |
| Exclusion Start | 192.168.20.1 |
| Exclusion End | 192.168.20.50 |
| Router | 192.168.20.10 |
| DNS Servers | 192.168.20.10 |
| DNS Domain Name | mabe.tso1 |
| Activate | Yes |

#### Scope 3: LAN-Este

| Campo | Valor |
|-------|-------|
| Name | LAN-Este |
| Start IP | 192.168.30.100 |
| End IP | 192.168.30.200 |
| Subnet mask | 255.255.255.0 |
| Exclusion Start | 192.168.30.1 |
| Exclusion End | 192.168.30.50 |
| Router | 192.168.30.10 |
| DNS Servers | 192.168.30.10 |
| DNS Domain Name | mabe.tso1 |
| Activate | Yes |

#### Scope 4: LAN-Sur

| Campo | Valor |
|-------|-------|
| Name | LAN-Sur |
| Start IP | 192.168.40.100 |
| End IP | 192.168.40.200 |
| Subnet mask | 255.255.255.0 |
| Exclusion Start | 192.168.40.1 |
| Exclusion End | 192.168.40.50 |
| Router | 192.168.40.10 |
| DNS Servers | 192.168.40.10 |
| DNS Domain Name | mabe.tso1 |
| Activate | Yes |

**Capturas obligatorias:**
- Los 4 scopes activos en la consola DHCP
- Detalle de cada scope con su rango de exclusión
- Opciones de cada scope (Router + DNS)

---

## 6. RRAS — Habilitar LAN routing en el DC (GUI)

> Esto permite que las sucursales lleguen a APP01 y entre ellas.

### 6.1 Instalar rol Remote Access

1. Server Manager → **Add Roles and Features**
2. Seleccionar **Remote Access** → Next
3. En **Role Services**, marcar **Routing** (NO DirectAccess, NO VPN)
4. Add Features → Next → Install
5. Esperar a que termine

### 6.2 Configurar RRAS

1. Abrir **Routing and Remote Access** (`rrasmgmt.msc`)
2. Click derecho sobre SRV-DC01 → **Configure and Enable Routing and Remote Access**
3. En el wizard:
   - Seleccionar **Custom configuration**
   - Marcar **LAN routing**
   - Click **Next** → **Finish**
4. Preguntará si iniciar el servicio → **Yes**
5. El servicio RRAS arranca

### 6.3 Verificar

1. En RRAS console, expandir SRV-DC01
2. **IPv4 → General** → deben aparecer las 4 interfaces
3. Cada interfaz debe estar "Enabled" para routing
4. Si una no aparece, click derecho → **Properties** → General → habilitar "IP routing"

**Capturas:**
- RRAS console con LAN routing habilitado
- Las 4 interfaces visibles y habilitadas
- Estado del servicio RRAS (Started)

**Snapshot:** `03_RRAS_OK`

---

## 7. AD Sites and Services — 4 sitios (GUI)

### 7.1 Abrir la consola

1. Abrir **Active Directory Sites and Services** (`dssite.msc`)
2. Por defecto existe el sitio **Default-First-Site-Name**

### 7.2 Crear 4 sitios

1. Click derecho sobre **Sites** → **New → Site**
2. Crear los 4 sitios:
   - Nombre: `SC-Central` → OK
   - Nombre: `SC-Norte` → OK
   - Nombre: `SC-Este` → OK
   - Nombre: `SC-Sur` → OK

3. Mover el DC al sitio Central:
   - Expandir `SC-Central` → debería estar vacío (o moverlo)
   - Expandir `Default-First-Site-Name` →Servers → SRV-DC01
   - Click derecho SRV-DC01 → **Move** → seleccionar `SC-Central`

4. Renombrar Default-First-Site-Name (opcional): click derecho → Rename → `SC-Central` (si prefieren no crear uno nuevo)

### 7.3 Crear 4 subredes

1. Click derecho sobre **Subnets** → **New → Subnet**
2. Crear las 4 subredes y asociarlas a su sitio:

| Address prefix | Site |
|----------------|------|
| 192.168.10.0/24 | SC-Central |
| 192.168.20.0/24 | SC-Norte |
| 192.168.30.0/24 | SC-Este |
| 192.168.40.0/24 | SC-Sur |

Para cada una:
   - Prefix: `192.168.10.0/24` (ejemplo Central)
   - Seleccionar site: `SC-Central`
   - OK

**Capturas:**
- Sites and Services con los 4 sitios
- Las 4 subredes asociadas a sus sitios
- SRV-DC01 en SC-Central

---

## 8. UO, grupos y usuarios (scripts)

### 8.1 Copiar scripts al DC

Copiar a una carpeta en SRV-DC01 (ej. `C:\Scripts\`):
- `05_Scripts/crear_ou_grupos.ps1`
- `05_Scripts/crear_usuarios.ps1`

> Usar Shared Folder de VirtualBox, drag&drop con Guest Additions, o USB.

### 8.2 Ejecutar

1. Abrir PowerShell como Administrador
2. Navegar a la carpeta donde copiaron los scripts
3. Habilitar ejecución temporal:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   ```
4. Ejecutar:
   ```powershell
   .\crear_ou_grupos.ps1
   .\crear_usuarios.ps1
   ```

### 8.3 Verificar en ADUC

1. Abrir **Active Directory Users and Computers** (`dsa.msc`)
2. Expandir `mabe.tso1`
3. Ver las 4 UO: `UO_SC_Central`, `UO_SC_Norte`, `UO_SC_Este`, `UO_SC_Sur`
4. Expandir cada UO → ver 3 grupos y 15 usuarios cada una

- [ ] 4 UO visibles
- [ ] 3 grupos por UO (12 total)
- [ ] 5+ usuarios por grupo (60 total)
- [ ] **Capturas** en `03_ou_usuarios_gpo/`

Password de los users: `User#Lab`

---

## 9. Unir SRV-APP01 al dominio (GUI)

1. En SRV-APP01, verificar que DNS apunta al DC:
   - `ncpa.cpl` → Ethernet → Properties → IPv4 → DNS = `192.168.10.10`
   - Gateway = `192.168.10.10`
2. Abrir CMD: `ping 192.168.10.10` → debe responder
3. `nslookup mabe.tso1` → debe resolver

Unir al dominio:
1. Settings → System → About → **Advanced system settings**
2. Computer Name tab → **Change**
3. Seleccionar **Domain** → escribir `mabe.tso1` → OK
4. Pedirá credenciales:
   - Usuario: `Administrator` o `mabe\Administrator`
   - Password: `Mabe#Lab2025`
5. Mensaje "Welcome to the mabe domain" → OK → Reiniciar

6. Login: `MABE\Administrator` con `Mabe#Lab2025`

**Captura:** System Properties mostrando Domain `mabe.tso1`

---

## 10. Unir los 4 clientes al dominio (GUI)

### 10.1 Verificar DHCP en cada cliente

En cada cliente, abrir CMD:

```cmd
ipconfig /release
ipconfig /renew
ipconfig /all
```

Verificar que recibe IP del scope correcto:

| Cliente | IP esperada | Gateway | DNS |
|---------|-------------|---------|-----|
| PC-REC01 (Central) | 192.168.10.x | 192.168.10.10 | 192.168.10.10 |
| PC-NORTE01 (Norte) | 192.168.20.x | 192.168.20.10 | 192.168.20.10 |
| PC-ESTE01 (Este) | 192.168.30.x | 192.168.30.10 | 192.168.30.10 |
| PC-SUR01 (Sur) | 192.168.40.x | 192.168.40.10 | 192.168.40.10 |

> Si un cliente no recibe IP, verificar que su adaptador esté en la red interna correcta.

### 10.2 Unir cada cliente al dominio

Repetir en cada cliente:
1. Settings → System → About → **Advanced system settings**
2. Computer Name tab → **Change**
3. Seleccionar **Domain** → escribir `mabe.tso1` → OK
4. Credenciales: `Administrator` / `Mabe#Lab2025`
5. Reiniciar
6. Login con usuario de dominio (ej. cualquier user del script, password `User#Lab`)

- [ ] PC-REC01 en dominio
- [ ] PC-NORTE01 en dominio
- [ ] PC-ESTE01 en dominio
- [ ] PC-SUR01 en dominio

**Capturas:**
- `ipconfig /all` de cada cliente (4 capturas, una por sucursal)
- Login exitoso de un usuario de dominio en cada sucursal
- En el DC: DHCP → Address Leases con los 4 clientes

**Snapshot:** `02_DHCP_CLIENT_OK`

---

## 11. RDP en DC (GUI)

1. En SRV-DC01: Settings → System → Remote Desktop → **Enable**
2. Seleccionar "Allow remote connections to this computer"
3. En Firewall: asegurar que el grupo "Remote Desktop" esté habilitado
4. Probar desde PC-REC01: `mstsc` → `192.168.10.10` → `MABE\Administrator`

**Captura** en `08_rdp/`

---

## 12. Cierre del Día 2 — checklist de aceptación

| # | Prueba | OK? |
|---|--------|-----|
| 1 | Dominio `mabe.tso1` existe | |
| 2 | DNS resuelve DC y APP | |
| 3 | 4 scopes DHCP activos | |
| 4 | Exclusión `.1-.50` visible en los 4 | |
| 5 | RRAS LAN routing habilitado | |
| 6 | 4 AD Sites + 4 Subnets | |
| 7 | 4 UO creadas | |
| 8 | 3 grupos por UO (12 total) | |
| 9 | ≥5 usuarios por grupo (60 total) | |
| 10 | APP01 en dominio | |
| 11 | 4 clientes con IP por DHCP | |
| 12 | Login usuario dominio en los 4 clientes | |
| 13 | Ping de un cliente Norte a `192.168.10.20` (APP01) funciona | |
| 14 | Navegación web desde Norte a `http://192.168.10.20` (si IIS ya está) | |
| 15 | Capturas guardadas | |
| 16 | Snapshots `01_AD_OK`, `03_RRAS_OK`, `02_DHCP_CLIENT_OK` | |

> El punto 13 valida que el routing funciona. Si un cliente en Norte llega a APP01 en la central, el RRAS está bien configurado.

### Prueba clave de routing

Desde PC-NORTE01 (IP 192.168.20.x):
```cmd
ping 192.168.10.20
```
Si responde, RRAS funciona. Si no, revisar:
- RRAS habilitado y servicio corriendo
- Gateway del cliente = IP del DC en su subred (192.168.20.10)
- Gateway de APP01 = 192.168.10.10

---

## Aún NO (Día 3)

- 15 GPO
- IIS, archivos, impresión, correo
- Hyper-V, backup

---

## Problemas frecuentes

| Síntoma | Causa probable | Solución |
|---------|----------------|----------|
| Cliente no recibe IP | Red interna incorrecta | Verificar adaptador en VirtualBox |
| Cliente recibe APIPA 169.254 | No llega al DHCP | Verificar red interna y que el DC tenga IP en esa subred |
| No encuentra dominio al unir | DNS del cliente no apunta al DC | Verificar DNS por DHCP o fijar manual |
| nslookup falla | DNS no instalado / zona mal | Revisar rol DNS y servicio |
| Ping Norte → APP01 falla | RRAS no habilitado o gateway mal | Revisar RRAS y gateways |
| Ping Norte → APP01 responde pero web no abre | Firewall de APP01 bloquea 80 | Habilitar HTTP en firewall de APP01 |
| No corre el script AD | No es DC / sin módulo | Promover primero; `Import-Module ActiveDirectory` |
| Password User#Lab rechazada | Política de complejidad | Tiene mayúscula, minúscula, símbolo y longitud 8. Debería pasar. |

---

## Orden de trabajo en grupo (reparto sugerido)

| Integrante | Tarea |
|------------|-------|
| 1 | Promover AD + capturas en DC01 |
| 2 | DNS + 4 scopes DHCP + capturas |
| 3 | RRAS LAN routing + AD Sites + capturas |
| 4 | Correr scripts UO/users + capturas ADUC |
| 5 | Unir APP01 + 4 clientes + pruebas ipconfig/login/ping routing |

Al terminar, avisen **listo dia 2** y seguimos con **15 GPO** y **SERVER2**.
