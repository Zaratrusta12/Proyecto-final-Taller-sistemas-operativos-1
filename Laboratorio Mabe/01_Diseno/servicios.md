# Matriz de servicios — Laboratorio Mabe

## Distribución por servidor

### SERVER1 — SRV-DC01 (`192.168.10.10`)

| Servicio | Detalle                                        | Prueba de aceptación                                 |
| -------- | ---------------------------------------------- | ---------------------------------------------------- |
| AD DS    | Dominio `mabe.tso1`                            | Login de usuario de dominio en cliente               |
| DNS      | Zona primaria `mabe.tso1`                      | `nslookup srv-dc01.mabe.tso1`                        |
| DHCP     | Scope + **1 exclusión** `.1-.50`               | `ipconfig /all` en cliente muestra DHCP y DNS del DC |
| UO       | Mín. 3: Recepción, Laboratorio, Administración | Visible en ADUC                                      |
| Grupos   | ≥ 3 por UO                                     | Visible en ADUC                                      |
| Usuarios | ≥ 5 por grupo                                  | Conteos / script                                     |
| GPO      | Mín. 15 con settings reales                    | `gpresult /r` en cliente                             |
| RDP      | Solo administradores                           | `mstsc` hacia DC                                     |
| Backup   | Windows Server Backup                          | Job Completed                                        |
| Hyper-V* | Nested o en APP01                              | 1 VM creada                                          |

\*Hyper-V puede instalarse en DC01 o APP01 según recursos y nested VT-x.

### SERVER2 — SRV-APP01 (`192.168.10.20`)

| Servicio  | Detalle                                     | Prueba de aceptación            |
| --------- | ------------------------------------------- | ------------------------------- |
| IIS       | Sitio Mabe, **5 páginas** HTML              | Navegación desde cliente        |
| Archivos  | Shares por área + NTFS por grupos           | Acceso OK / denegado cruzado    |
| Cuotas    | FSRM distintas por grupo/carpeta            | Consola FSRM + prueba de límite |
| Impresión | **1 impresora compartida por UO** (3 total) | Usuario ve su impresora         |
| Correo    | hMailServer dominio `mabe.tso1`             | Envío/recepción interna         |
| RDP       | Solo administradores                        | Conexión admin                  |

### ESTACIÓN — PC-REC01

| Uso        | Detalle                                                        |
| ---------- | -------------------------------------------------------------- |
| Validación | DHCP, dominio, GPO, web, shares, impresoras, correo, RDP admin |

## Sitio web (5 páginas)

| Archivo          | Contenido                            |
| ---------------- | ------------------------------------ |
| `index.html`     | Inicio / bienvenida Laboratorio Mabe |
| `servicios.html` | Análisis y servicios del laboratorio |
| `horarios.html`  | Horarios de atención en Santa Cruz   |
| `contacto.html`  | Teléfono, correo, dirección          |
| `nosotros.html`  | Misión, visión, calidad              |

Ruta sugerida en servidor: `C:\inetpub\wwwroot\mabe\`  
URL de prueba: `http://srv-app01.mabe.tso1` o `http://192.168.10.20`

## Carpetas compartidas y permisos (esquema)

```
D:\DatosMabe\   (o C:\DatosMabe\ si no hay segundo disco)
├── Recepcion\        → G_Rec_*  Modify | Administrators Full
├── Laboratorio\      → G_Lab_*  Modify | Administrators Full
├── Administracion\   → G_Adm_*  Modify | Administrators Full
└── Publico\          → Usuarios autenticados Read
```

Cuotas ejemplo (FSRM):

| Carpeta        | Cuota | Grupo objetivo     |
| -------------- | ----- | ------------------ |
| Recepcion      | 2 GB  | G_Rec_Usuarios     |
| Laboratorio    | 5 GB  | G_Lab_Analistas    |
| Administracion | 3 GB  | G_Adm_Contabilidad |

## Impresoras

| Nombre cola        | UO / GPO          | Notas                                    |
| ------------------ | ----------------- | ---------------------------------------- |
| IMP-Recepcion      | UO_Recepcion      | Driver genérico / Microsoft Print to PDF |
| IMP-Laboratorio    | UO_Laboratorio    | Idem                                     |
| IMP-Administracion | UO_Administracion | Idem                                     |

## Correo

| Parámetro    | Valor                                                     |
| ------------ | --------------------------------------------------------- |
| Software     | hMailServer                                               |
| Dominio      | `mabe.tso1`                                               |
| Cuentas demo | `recepcion@mabe.tso1`, `lab@mabe.tso1`, `admin@mabe.tso1` |
| Puertos      | SMTP 25, POP3 110, IMAP 143 (lab interno)                 |

## Seguridad (resumen)

- GPO de contraseñas y bloqueo de cuentas
- GPO de restricción USB, bloqueo de pantalla, mapeo de unidades
- Firewall de Windows con reglas por rol
- RDP solo para Domain Admins / grupo admin
- Datos de pacientes: **siempre ficticios** en demos y capturas
