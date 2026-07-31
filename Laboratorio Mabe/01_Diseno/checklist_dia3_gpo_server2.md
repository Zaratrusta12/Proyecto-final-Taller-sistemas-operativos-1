# Checklist Día 3 — GPO + SERVER2 (IIS, Archivos, Impresión, Correo)

**Precondiciones (Día 2 completado):**

- [x] Dominio `mabe.tso1` operativo
- [x] DNS con 4 zonas directas + 4 inversas, registros A y PTR
- [x] 4 scopes DHCP activos con exclusión `.1-.50` (entregable `.51-.200`)
- [x] RRAS LAN routing habilitado, ping Norte → APP01 funciona
- [x] 4 AD Sites + 4 Subnets
- [x] 4 UO, 12 grupos, 60 usuarios
- [x] APP01 y 4 clientes unidos al dominio
- [x] RDP en DC probado

**Idioma:** Windows Server y clientes en español. Configuraciones por GUI, todos los nombres en español.

**Capturas:** `02_Implementacion/capturas/03_ou_usuarios_gpo/` y `04_iis_web/` a `07_correo/`

---

## PARTE A — 15 GPO (en SRV-DC01)

### A.1 Abrir GPMC

1. En SRV-DC01, abrir **Administrador del servidor** → **Herramientas** → **Administración de directivas de grupo** (`gpmc.msc`)
2. Expandir **Bosque: mabe.tso1 → Dominios → mabe.tso1**

### A.2 Crear las 15 GPO

Para cada GPO de la tabla:

1. Click derecho sobre `mabe.tso1` (o el Sitio/UO correspondiente) → **Crear un GPO en este dominio y vincularlo aquí...**
2. Escribir el nombre exacto (ej. `GPO_PasswordPolicy`) → Aceptar
3. Click derecho sobre la GPO nueva → **Editar** → navegar hasta la ruta de la tabla y configurar el parámetro

### A.3 Tabla de las 15 GPO

| #   | Nombre                     | Enlace          | Qué configurar (en español)                                                                                                                                                          |
| --- | -------------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | `GPO_PasswordPolicy`       | Dominio         | Conf. equipo → Directivas → Conf. de Windows → Conf. de seguridad → Directivas de cuenta → Directiva de contraseñas: long. mín. 8, complejidad habilitada, historial 5, máx. edad 90 |
| 2   | `GPO_AccountLockout`       | Dominio         | Misma ruta → Directiva de bloqueo de cuentas: 5 intentos, duración 30, reset 30                                                                                                      |
| 3   | `GPO_ScreenLock`           | Dominio         | Conf. de usuario → Directivas → Plantillas admin. → Panel de control → Personalización: tempo protector 300, exigir contraseña al reanudar = Habilitado                              |
| 4   | `GPO_Restrict_USB`         | Dominio         | Conf. equipo → Plantillas admin. → Sistema → Acceso a almacenamiento extraíble: denegar escritura = Habilitado                                                                       |
| 5   | `GPO_WindowsUpdate`        | Dominio         | Conf. equipo → Plantillas admin. → Componentes de Windows → Windows Update: conf. actualizaciones automáticas = Habilitado, opción 4                                                 |
| 6   | `GPO_Firewall_Baseline`    | Dominio         | Conf. equipo → Conf. de Windows → Conf. de seguridad → Firewall de Windows Defender: perfil de dominio = Habilitado (firewall)                                                       |
| 7   | `GPO_Disable_ControlPanel` | `UO_SC_Central` | Conf. usuario → Plantillas admin. → Panel de control: impedir acceso a Panel de control y Configuración = Habilitado                                                                 |
| 8   | `GPO_Disable_CMD`          | `UO_SC_Central` | Conf. usuario → Plantillas admin. → Sistema: impedir acceso al símbolo del sistema = Habilitado                                                                                      |
| 9   | `GPO_Map_Drive_Central`    | `UO_SC_Central` | Conf. usuario → Preferencias → Conf. de Windows → Unidades asignadas: nueva → `R:` → `\\SRV-APP01\Central`                                                                           |
| 10  | `GPO_Map_Drive_Norte`      | `UO_SC_Norte`   | `S:` → `\\SRV-APP01\Norte`                                                                                                                                                           |
| 11  | `GPO_Map_Drive_Este`       | `UO_SC_Este`    | `S:` → `\\SRV-APP01\Este`                                                                                                                                                            |
| 12  | `GPO_Map_Drive_Sur`        | `UO_SC_Sur`     | `S:` → `\\SRV-APP01\Sur`                                                                                                                                                             |
| 13  | `GPO_Deploy_Printer_Norte` | `UO_SC_Norte`   | Conf. usuario → Preferencias → Conf. del Panel de control → Impresoras: nueva → `\\SRV-APP01\IMP-Norte`                                                                              |
| 14  | `GPO_Deploy_Printer_Este`  | `UO_SC_Este`    | `\\SRV-APP01\IMP-Este`                                                                                                                                                               |
| 15  | `GPO_Deploy_Printer_Sur`   | `UO_SC_Sur`     | `\\SRV-APP01\IMP-Sur`                                                                                                                                                                |

> Nota: las GPO de unidades mapeadas e impresoras necesitan que los shares correspondientes existan en APP01. Si no están aún, crear las GPO igual y reiniciar/actualizar después de configurar los shares.

- [ ] 15 GPO creadas con nombres exactos
- [ ] Cada una con al menos un parámetro habilitado/configurado
- [ ] Enlazadas al nivel correcto (dominio, UO o sitio)
- [ ] **Captura** de GPMC con el árbol completo

### A.4 Probar GPO en cliente (Central)

En PC-REC01, login con un usuario de `UO_SC_Central` (password `User#Lab`):

- [ ] `gpupdate /force` (CMD como admin)
- [ ] `gpresult /r` → muestra las GPO aplicadas
- [ ] Verificar:
  - Unidad `R:` mapeada (abrir Equipo)
  - Panel de control bloqueado (si aplicó #7)
  - CMD bloqueado (si aplicó #8)
  - Protector de pantalla configurado
  - USB restringido (probar conectar USB virtual)
- [ ] **Capturas** de cada verificación

### A.5 Probar GPO en cliente de otra sucursal

Encender PC-NORTE01, login con usuario de `UO_SC_Norte`:

- [ ] `gpupdate /force` + `gpresult /r`
- [ ] Unidad `S:` mapeada a `\\SRV-APP01\Norte`
- [ ] Impresora `IMP-Norte` instalada (si el share ya existe)
- [ ] **Captura** de `gpresult` mostrando GPO de Norte aplicadas

> Repetir lo mínimo para Este y Sur (al menos `gpresult` de cada una).

**Snapshot:** `04_GPO_OK`

---

## PARTE B — SERVER2: IIS (sitio web 5 páginas)

### B.1 Instalar rol IIS (GUI)

1. En SRV-APP01, abrir **Administrador del servidor** → **Agregar roles y características**
2. Tipo de instalación: **Instalación basada en roles o características**
3. Servidor: SRV-APP01
4. Marcar **Servidor Web (IIS)** → Agregar características → Siguiente
5. En **Servicios de rol**, dejar los predeterminados + marcar:
   - **HTTP** (ya viene)
   - **Documentación predeterminada** (ya viene)
   - **Exploración de directorios** (opcional)
   - **Página de inicio predeterminada** (ya viene)
   - **ASP.NET** (opcional si quieren algo más)
6. Siguiente → Instalar
7. Esperar a que termine

**Captura:** wizard de instalación completado

### B.2 Preparar carpeta del sitio

1. Abrir Explorador de archivos en SRV-APP01
2. Crear `C:\inetpub\wwwroot\mabe\`
3. Dentro, crear 5 archivos HTML simples:

| Archivo          | Contenido                                                          |
| ---------------- | ------------------------------------------------------------------ |
| `index.html`     | Página de inicio Laboratorio Mabe (logo, bienvenida, 4 sucursales) |
| `servicios.html` | Análisis y servicios del laboratorio                               |
| `horarios.html`  | Horarios de las 4 sucursales en Santa Cruz                         |
| `contacto.html`  | Teléfono, correo, direcciones por sucursal                         |
| `nosotros.html`  | Misión, visión, calidad                                            |

> Usar HTML básico con un menú común en todas las páginas (Inicio, Servicios, Horarios, Contacto, Nosotros).
> No necesita CSS complejo. TEXTIL suficiente para demo.
> Plantilla HTML simple ver en `05_Scripts/templates_web/` (si la creo) o escribir a mano.

### B.3 Configurar sitio en IIS (GUI)

1. Abrir **Administrador de Internet Information Services (IIS)** (`inetmgr.msc`)
2. Expandir SRV-APP01 → Sitios
3. Click derecho sobre **Sitios** → **Agregar sitio web...**
4. Configurar:
   - Nombre del sitio: `MabeWeb`
   - Ruta de acceso física: `C:\inetpub\wwwroot\mabe\`
   - Enlace: tipo `http`, dirección IP `Todas las no asignadas`, puerto `80` (o 8080 si 80 está ocupado por Default Web Site)
   - Nombre de host: (vacío por ahora, opcional `srv-app01.mabe.tso1`)
   - Iniciar sitio web inmediatamente: marcado
5. Aceptar
6. Si el puerto 80 está ocupado por **Default Web Site**, detenerlo:
   - Click derecho sobre **Default Web Site** → **Administrar sitio web** → Detener
   - O cambiar el puerto del Default a 8080

### B.4 Probar el sitio desde APP01

1. En SRV-APP01, abrir navegador → `http://localhost`
2. Debe cargar `index.html` de Mabe
3. Navegar por las 5 páginas (menú)

**Capturas:**

- IIS Manager con el sitio MabeWeb
- Navegador mostrando las 5 páginas

### B.5 Probar desde clientes (routing)

1. En PC-REC01 (central): `http://192.168.10.20` o `http://srv-app01.mabe.tso1`
2. En PC-NORTE01: `http://192.168.10.20` (vía routing_rras)
3. En PC-ESTE01 y PC-SUR01 (al encenderlos)
- [ ] Web accessible desde Central
- [ ] Web accessible desde Norte (vía routing)
- [ ] **Capturas** de navegador en cada sucursal

**Captura** en `04_iis_web/`.

**Snapshot:** `05_IIS_OK`

---

## PARTE C — Archivos y Cuotas

### C.1 Preparar carpetas (GUI)

1. En SRV-APP01, abrir Explorador
2. Crear `D:\DatosMabe\` (o `C:\DatosMabe\` si no hay segundo disco)
3. Subcarpetas:

```
D:\DatosMabe\
├── Central\
├── Norte\
├── Este\
├── Sur\
├── Publico\
```

> Estructura por sucursal: cada una tiene su carpeta compartida.

### C.2 Compartir carpetas con permisos NTFS (GUI)

Para cada carpeta de sucursal:

1. Click derecho sobre la carpeta → **Propiedades** → pestaña **Uso compartido** → **Uso compartido avanzado...**
2. Marcar "Compartir esta carpeta"
3. Nombre del recurso: igual que la carpeta (ej. `Central`)
4. Click **Permisos** → agregar el grupo correspondiente:
   - `Central` → grupo `G_Central_Usuarios` (Control total) + `G_Central_Supervisores` (Control total)
   - `Norte` → `G_Norte_Usuarios` + `G_Norte_Supervisores`
   - `Este` → `G_Este_Usuarios` + `G_Este_Supervisores`
   - `Sur` → `G_Sur_Usuarios` + `G_Sur_Supervisores`
   - `Publico` → `Usuarios autenticados` (Lectura)
5. En pestaña **Seguridad** (NTFS):
   - Quitar "Todos" si está
   - Agregar grupo correspondiente con permisos "Modificar" (no Control total)
   - Dejar `Administradores` con Control total
   - Principio: usuarios de la sucursal solo acceden a su carpeta
6. Aceptar
- [ ] 5 carpetas compartidas
- [ ] Permisos NTFS por grupo de sucursal
- [ ] **Captura** de permisos de cada carpeta

### C.3 Verificar acceso desde cliente

En PC-REC01 (central), login con usuario de `UO_SC_Central`:

- [ ] `\\SRV-APP01\Central` accessible (escribir/crear documento de prueba)
- [ ] `\\SRV-APP01\Norte` NO es accesible (acceso denegado)
- [ ] `\\SRV-APP01\Publico` accesible (solo lectura)

En PC-NORTE01, login con usuario de `UO_SC_Norte`:

- [ ] `\\SRV-APP01\Norte` accessible
- [ ] `\\SRV-APP01\Central` NO accesible
- [ ] **Capturas** del acceso y denegación cruzada (importante para defensa)

### C.4 Cuotas de disco (GUI)

1. En SRV-APP01, abrir **Explorador** → click derecho en `D:` (o `C:`) → **Propiedades** → pestaña **Cuota** → **Mostrar información de cuota**
2. Marcar **Habilitar la administración de cuotas**
3. Marcar **Denegar nuevo espacio de disco a usuarios que excedan el límite**
4. Límite de volumen: 2 GB (ejemplo)
5. Nivel de advertencia: 1.8 GB
6. Aplicar a los grupos de sucursal por separado con **Configuración de cuota elevada**:
   - Click derecho sobre un usuario en la lista → **Propiedades** → fijar límite distinto
   - O configurar plantillas FSRM si está instalado el rol

> Simplificado: cuota global de 2 GB con diferentes ajustes manuales. Si quieren FSRM con plantillas ver
> el README_PROYECTO.

- [ ] Cuota habilitada en el volumen

- [ ] Límite de 2 GB de ejemplo

- []Una captura de la ventana de cuotas

- [ ] **Captura** en `05_archivos_cuotas/`

**Snapshots:** `06_Archivos_Cuotas_OK`

---

## PARTE D — Impresión (1 impresora por sucursal)

### D.1 Instalar rol de Impresión (GUI)

1. Administrador del servidor → Agregar roles
2. Marcar **Servicio de impresión y documentos**
3. En servicios de rol:
   - **Servidor de impresión** (marcar)
   - **Servidor de impresión LDAP** (opcional)
   - **Administración de impresión** (marcar)
4. Instalar
5. Esperar

### D.2 Crear 4 impresoras (GUI)

1. Abrir **Administración de impresión** (`printmanagement.msc`)
2. Expandir SRV-APP01 → Servidores → SRV-APP01
3. Click derecho sobre **Impresoras** → **Agregar impresora...**
4. Seleccionar **Agregar una impresora TCP/IP por dirección IP** (opcional) o **Agregar una impresora local**
5. Usar puerto TCP-IP con una IP de la tabla de impresoras (documentadas):
   - `IMP-Norte` → `192.168.20.30`
   - `IMP-Este` → `192.168.30.30`
   - `IMP-Sur` → `192.168.40.30`
   - `IMP-Central` → `192.168.10.30`
6. Driver: **Microsoft Print to PDF** o **Generic / Text Only** (no hay impresora física)
7. Nombre de la impresora: `IMP-Norte`, `IMP-Este`, `IMP-Sur`, `IMP-Central`
8. Compartir: marcar "Compartir esta impresora" con el mismo nombre
9. Siguiente → Siguiente → Finalizar
- [ ] 4 impresoras creadas (una por sucursal)
- [ ] Todas compartidas
- [ ] **Captura** de la consola Administración de impresión con las 4

### D.3 Verificar desde clientes (GPO ya hecha en Parte A)

En PC-NORTE01 (login con usuario de `UO_SC_Norte`):

- [ ] `gpupdate /force`
- [ ] Abrir **Dispositivos e impresoras** → debe aparecer `IMP-Norte`
- [ ] (Opcional) Imprimir página de prueba
- [ ] **Captura**

Repetir para PC-ESTE01 (`IMP-Este`), PC-SUR01 (`IMP-Sur`) y PC-REC01 (`IMP-Central`).

- [ ] 4 capturas (1 por sucursal) mostrando su impresora instalada

**Captura** en `06_impresion/`.

**Snapshot:** `07_Impresion_OK`

---

## PARTE E — Correo (hMailServer)

### E.1 Instalar hMailServer

> Es software de terceros. Descargar desde https://www.hmailserver.com/ (versión gratuita).
> Instalar en SRV-APP01.

1. Ejecutar instalador
2. Elegir instancia **Standard** (gratuita)
3. Usar contraseña de admin de hMailServer: `Mabe#Lab2025`
4. Finalizar instalación

### E.2 Configurar dominio y cuentas (GUI)

1. Abrir **hMailServer Administrator**
2. Conectar a localhost (password `Mabe#Lab2025`)
3. **Dominios** → Click derecho → **Agregar...**
   - Nombre: `mabe.tso1`
4. Expandir `mabe.tso1` → **Cuentas** → Agregar 3 cuentas:
   - `recepcion@mabe.tso1` (password `User#Lab`)
   - `lab@mabe.tso1` (password `User#Lab`)
   - `admin@mabe.tso1` (password `User#Lab`)
5. En **Protocolos** → **SMTP** → Puerto 25 (default)
6. En **Protocolos** → **POP3** → Puerto 110 (default)
7. En **Protocolos** → **IMAP** → Puerto 143 (default)
- [ ] Dominio `mabe.tso1` configurado
- [ ] 3 cuentas creadas
- [ ] SMTP, POP3, IMAP habilitados
- [ ] **Captura** de la consola de hMailServer

### E.3 Instalar cliente de correo en PC-REC01

> Opciones: Mozilla Thunderbird (gratuito, fácil) o la app Correo de Windows.

1. Descargar e instalar **Mozilla Thunderbird** en PC-AC01
   2 Configurar cuenta para `recepcion.mabe.tso1`:
   - Nombre: Recepción Mabe
   - Correo: `recepcion@mabe.tso1`
   - Contraseña: `User#Lab`
   - Servidor entrante (IMAP): `192.168.10.20`, puerto 143, sin SSL
   - Servidor saliente (SMTP): `192.168.10.20`, puerto 25, sin SSL
   - Sin autenticación segura (lab interno)
2. Repetir para `lab@mabe.tso1` y `admin@mabe.tso1` si quieren probar envío/recepción

### E.4 Prueba de envío/recepción

1. Conectado como `recepcion@mabe.tso1` → redactar correo a `lab@mabedomain`
2. Enviar
3. Configurar cuenta `lab@mabe.tso1` en otra pestaña/instancia → recibir correo
4. Verificar en hMailServer → **Herramientas** → **Registro** → ver transacciones SMTP
- [ ] Correo enviado y recibido
- [ ] **Captura** de Thunderbird con el correo recibido
- [ ] **Captura** del log de hMailServer

**Captura** en `07_correo/`.

**Snapshot:** `08_Correo_OK`

---

## PARTE F — RDP en APP01

### F.1 Habilitar RDP (GUI)

1. En SRV-APP01: Configuración → Sistema → Escritorio remoto → **Habilitar**
2. Permitir conexiones remotas
3. Firewall: asegurar regla de Escritorio remoto habilitada (por defecto ya lo está)

### F.2 Probar desde cliente

En PC-RC01 (con usuario admin del dominio):

- [ ] `mstsc` → `192.168.10.20` → login `MABE\Administrator` con `Mabe#Lab2025`
- [ ] Conexión exitosa
- [ ] **Captura**

**Captura** en `08_rdp/`.

---

## PARTE G — Cierre del Día 3 — checklist de aceptación

| #   | Prueba                                             | OK?                                                                   |
| --- | -------------------------------------------------- | --------------------------------------------------------------------- |
| 1   | 15 GPO creadas con nombre exacto                   | x                                                                     |
| 2   | Cada GPO con al menos un parámetro configurado     | x                                                                     |
| 3   | GPO enlazadas a dominio/UO/sitio correcto          | x                                                                     |
| 4   | `gpresult /r` muestra GPO aplicadas en Central     | x                                                                     |
| 5   | `gpresult /r` muestra GPO aplicadas en Norte       | x                                                                     |
| 6   | Unidad mapeada `R:` visible en Central             | x                                                                     |
| 7   | Unidad mapeada `S:` visible en Norte               | x                                                                     |
| 8   | IIS instalado, sitio MabeWeb creado                | x                                                                     |
| 9   | 5 páginas HTML accesibles                          | x                                                                     |
| 10  | Web accesible desde Central                        | x                                                                     |
| 11  | Web accesible desde Norte (vía routing)            | x                                                                     |
| 12  | 5 carpetas compartidas con permisos NTFS por grupo | x                                                                     |
| 13  | Acceso cruzado denegado (Central no entra a Norte) | x                                                                     |
| 14  | Cuota de disco habilitada                          | x                                                                     |
| 15  | 4 impresoras compartidas (1 por sucursal)          | x                                                                     |
| 16  | Impresora correcta visible en cada sucursal        | x                                                                     |
| 17  | hMailServer instalado, dominio `mabe.tso1`         | no                                                                    |
| 18  | 3 cuentas de correo creadas                        | no                                                                    |
| 19  | Correo enviado y recibido                          | no                                                                    |
| 20  | RDP en APP01 funciona                              | x                                                                     |
| 21  | Capturas guardadas en todas las carpetas           | ver docs y md                                                         |
| 22  | Snapshots `04_GPO_OK` a `08_Correo_OK`             | evitar snapshots por problemas de compatibilidad con Active Directory |

---

## Aún NO (Día 4)

- Hyper-V nested
- Windows Server Backup
- Firewall con reglas por servicio
- Pruebas finales
- Informe

---

## Problemas frecuentes

| Síntoma                      | Causa                             | Solución                                              |
| ---------------------------- | --------------------------------- | ----------------------------------------------------- |
| GPO no se aplica             | Enlace mal o herencia bloqueada   | Revisar GPMC, verificar enlace y "Herencia bloqueada" |
| Unidad mapeada no aparece    | Share no existe aún o permisos    | Verificar share en APP01 y permisos NTFS              |
| Impresora no instala por GPO | Share no existe o puerto mal      | Verificar impresora compartida en APP01               |
| Web no abre desde Norte      | Firewall de APP01 bloque 80       | Habilitar regla HTTP entrante en firewall de APP01    |
| Web abre pero blanco         | index.html no en la ruta correcta | Verificar ruta física en IIS y contenido              |
| Correo no llega              | Firewall bloquea 25/110/143       | Habilitar puertos en firewall de APP01                |
| Cuotas no aparecen           | Volumen formateado NTFS req       | Verificar sistema de archivos del volumen             |

---

## Orden de trabajo en grupo (reparto sugerido)

| Integrante | Tarea                                            |
| ---------- | ------------------------------------------------ |
| 1          | 15 GPO + pruebas gpresult en clientes (Parte A)  |
| 2          | IIS + 5 páginas HTML (Parte B)                   |
| 3          | Archivos + cuotas + permisos + pruebas (Parte C) |
| 4          | Impresión + pruebas por sucursal (Parte D)       |
| 5          | Correo hMailServer + RDP (Partes E+F)            |

> Si hay cuello de botella, la Parte A (GPO) puede hacerse mientras otros instalan IIS/Archivo/Impresión,
> porque las GPO de mapeo/impresora se prueban al final una vez existan los shares.

Al terminar, avisan **listo dia 3** y seguimos con **Día 4: Hyper-V + Backup + Firewall + Pruebas finales**.

# notas importantes personal

- al usar clones de vm se repiten las contraseñas seguras y el AD evite iniciar sesion, evaluar forma de evitar eso

- prepararme un md listo con cada usuario segun su grupo para cada sucursal, asi se que nombre de usuario poner para probrar distintos permisos

- se omitio el servidor de correo al no ser un rol nativo de windows server, eliminar todo mencion de servidor de correo en documentacion y futuro informe

- No incluir en el informe el uso de snapshots en las maquinas virtuales