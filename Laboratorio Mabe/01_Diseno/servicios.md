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

## Carpetas compartidas y permisos (esquema por sucursal)

```
D:\DatosMabe\   (o C:\DatosMabe\ si no hay segundo disco)
├── Central\        → G_Central_Usuarios + G_Central_Supervisores (Modify) | Administradores (Full)
├── Norte\          → G_Norte_Usuarios + G_Norte_Supervisores (Modify) | Administradores (Full)
├── Este\           → G_Este_Usuarios + G_Este_Supervisores (Modify) | Administradores (Full)
├── Sur\            → G_Sur_Usuarios + G_Sur_Supervisores (Modify) | Administradores (Full)
└── Publico\        → Usuarios autenticados (Read)
```

> Implementado en el Día 3: 5 carpetas compartidas, permisos NTFS por grupo de sucursal, herencia deshabilitada, "Usuarios" local eliminado de cada share. Denegación cruzada verificada (ej. usuario de Norte no entra a Central).

Cuota de disco (implementado en el Día 3):
- Cuota global habilitada en volumen C: de SRV-APP01
- Límite: 2 GB, nivel de advertencia 1.8 GB
- Verificado desde cliente: límite visible

## Impresoras (1 por sucursal, implementado en Día 3)

| Nombre cola | Sucursal / GPO | Driver | Notas |
|-------------|----------------|--------|-------|
| IMP-Central | UO_SC_Central | Genérico IBM | Cola local en APP01 |
| IMP-Norte | UO_SC_Norte | Genérico IBM | Cola local en APP01 |
| IMP-Este | UO_SC_Este | Genérico IBM | Cola local en APP01 |
| IMP-Sur | UO_SC_Sur | Genérico IBM | Cola local en APP01 |

> Implementado con 4 impresoras genéricas IBM en APP01, compartidas y desplegadas por GPO.
> Las IPs de impresoras en `direccionamiento_ip.md` son referenciales para la documentación; lo implementado usa colas locales sin puerto TCP/IP físico.

## Correo

| Parámetro | Valor |
|-----------|--------|
| Software | hMailServer |
| Dominio | `mabe.tso1` |
| Cuentas demo | `recepcion@mabe.tso1`, `lab@mabe.tso1`, `admin@mabe.tso1` |
| Puertos | SMTP 25, POP3 110, IMAP 143 (lab interno) |

## Seguridad (resumen)

- GPO de contraseñas y bloqueo de cuentas (dominio)
- GPO de restricción USB, bloqueo de pantalla, mapeo de unidades (dominio)
- GPO de restricción de Panel de control y CMD (UO_SC_Central)
- GPO de despliegue de impresoras por sucursal (UO)
- Firewall de Windows con reglas por rol
- RDP solo para administradores (DC + APP01)
- RRAS: routing inter-VLAN, sin exposición externa
- Archivos: permisos NTFS por grupo de sucursal, denegación cruzada
- Cuotas de disco habilitadas (2 GB)
- Datos de pacientes: **siempre ficticios** en demos y capturas
