# Matriz de servicios — Laboratorio Mabe (4 sucursales)

## Distribución por servidor

### SERVER1 — SRV-DC01 (4 NICs, router inter-VLAN)

| IP por sucursal | Servicio | Detalle |
|-----------------|----------|---------|
| `.10` en cada subred | AD DS | Dominio `mabe.tso1`, 4 Sites |
| `.10` en cada subred | DNS | Zona `mabe.tso1`, registros A de ambos servers |
| `.10` en cada subred | DHCP | 4 scopes (uno por sucursal), cada uno con exclusión `.1-.50` |
| `.10` en cada subred | RRAS | LAN routing entre las 4 subredes |
| `.10` en cada subred | GPO | 15 GPO (algunas enlazadas por Sitio) |
| `.10` en cada subred | RDP | Solo administradores |
| `.10` en cada subred | Backup | Windows Server Backup |
| `.10` en cada subred | Hyper-V* | Nested o en APP01 |

\*Hyper-V puede ir en DC01 o APP01 según recursos y nested VT-x.

### SERVER2 — SRV-APP01 (1 NIC, red central)

| IP | Servicio | Detalle | Prueba de aceptación |
|----|----------|---------|----------------------|
| `192.168.10.20` | IIS | Sitio Mabe, 5 páginas HTML | Navegación desde cualquier sucursal |
| `192.168.10.20` | Archivos | Shares por área + NTFS por grupos | Acceso OK / denegado cruzado |
| `192.168.10.20` | Cuotas | FSRM distintas por grupo/carpeta | Consola FSRM |
| `192.168.10.20` | Impresión | 1 impresora compartida por UO | Usuario ve su impresora |
| `192.168.10.20` | Correo | hMailServer dominio `mabe.tso1` | Envío/recepción interna |
| `192.168.10.20` | RDP | Solo administradores | Conexión admin desde cualquier sucursal |

> APP01 es single-homed (1 NIC). Las sucursales llegan a APP01 vía routing del DC (RRAS).

### Estaciones de trabajo (4, una por sucursal)

| VM | Sucursal | Red interna | Validación |
|----|----------|-------------|------------|
| PC-REC01 | Central | intnet-mabe-central | DHCP, dominio, GPO, web, shares, impresoras, correo, RDP admin |
| PC-NORTE01 | Norte | intnet-mabe-norte | DHCP, dominio, GPO, web (vía routing), shares, impresoras |
| PC-ESTE01 | Este | intnet-mabe-este | Idem Norte |
| PC-SUR01 | Sur | intnet-mabe-sur | Idem Norte |

> Para demos: encender DC + APP01 + 1 cliente a la vez.

## Sitio web (5 páginas)

| Archivo | Contenido |
|---------|-----------|
| `index.html` | Inicio / bienvenida Laboratorio Mabe |
| `servicios.html` | Análisis y servicios del laboratorio |
| `horarios.html` | Horarios de atención (4 sucursales) |
| `contacto.html` | Teléfono, correo, dirección por sucursal |
| `nosotros.html` | Misión, visión, calidad |

Ruta en servidor: `C:\inetpub\wwwroot\mabe\`  
URL: `http://srv-app01.mabe.tso1` o `http://192.168.10.20`

## Carpetas compartidas y permisos (esquema)

```
D:\DatosMabe\
├── Recepcion\        → G_Rec_*  Modify | Administrators Full
├── Laboratorio\      → G_Lab_*  Modify | Administrators Full
├── Administracion\   → G_Adm_*  Modify | Administrators Full
└── Publico\          → Usuarios autenticados Read
```

Cuotas FSRM:
- Recepcion: 2 GB
- Laboratorio: 5 GB
- Administracion: 3 GB

## Impresoras (1 por UO/sucursal)

| Nombre cola | UO / GPO | Notas |
|-------------|----------|-------|
| IMP-Central | UO_SC_Central | Driver genérico / Microsoft Print to PDF |
| IMP-Norte | UO_SC_Norte | Idem |
| IMP-Este | UO_SC_Este | Idem |
| IMP-Sur | UO_SC_Sur | Idem |

## Correo

| Parámetro | Valor |
|-----------|--------|
| Software | hMailServer |
| Dominio | `mabe.tso1` |
| Cuentas demo | `recepcion@mabe.tso1`, `lab@mabe.tso1`, `admin@mabe.tso1` |
| Puertos | SMTP 25, POP3 110, IMAP 143 (lab interno) |

## Seguridad (resumen)

- GPO de contraseñas y bloqueo de cuentas
- GPO de restricción USB, bloqueo de pantalla, mapeo de unidades
- Firewall de Windows con reglas por rol
- RDP solo para Domain Admins / grupo admin
- RRAS: routing inter-VLAN, sin exposición externa
- Datos de pacientes: **siempre ficticios** en demos y capturas
