# Revisión de documentación — Repaso general (pre-Día 4)

**Fecha:** 2026-07-30  
**Objetivo:** verificar que toda la documentación coincide con lo Implementado en los Días 1, 2.5 (scripts/capturas), 3 antes de seguir al Día 4.

---

## 1. Inventario de lo que existe

### Documentos de diseño (`01_Diseno/`)

| Archivo | Estado | Observación |
|---------|--------|-------------|
| `direccionamiento_ip.md` | Actualizado | 4 subredes, scopes `.1-.200` excl `.1-.50` (entregable `.51-.200`), nota crítica de NICs |
| `servicios.md` | Actualizado | DC 4-NIC + RRAS, APP01 single-NIC |
| `empresa_mabe.md` | Actualizado | 4 sucursales, 4 UO, 12 grupos, 60 usuarios |
| `resumen_sucursales_4.md` | Actualizado | Resumen simple con DHCP corregido |
| `checklist_dia1_virtualbox.md` | Actualizado | 6 VMs, 4 redes, clonado de clientes |
| `checklist_dia2_ad_dns_dhcp.md` | Actualizado con notas reales | Nota crítica NICs, scopes `.1-.200`, zonas inversas, en español |
| `checklist_dia3_gpo_server2.md` | Actualizado | 15 GPO, IIS, archivos, impresión, correo, RDP en español |
| `evaluacion_4redes_dhcp.md` | Histórico | Análisis de opciones, se eligió Opción 1 (DC 4-NIC) |
| `evaluacion_acceso_app01_sucursales.md` | Histórico | Se eligió Opción B (RRAS) |
| `topologia/TOPOLOGIA MABE.drawio.png` | Nueva | Enviada por el usuario, 4 sucursales visible |
| `topologia/REVISION_topologia.md` | Histórico | Revisión de la topología anterior (ya reemplazada) |
| `topologia/README_topologia.md` | Histórico | Guía inicial, queda como referencia |
| `Usuarios en cada maquina.md` | Nuevo (del usuario) | Lista 4 usuarios de prueba por sucursal |

### Documentos de implementación (`02_Implementacion/capturas/`)

| Archivo | Estado | Día | Cobertura |
|---------|--------|-----|-----------|
| `Capturas y proceso Dia 1.docx` | Completo | 1 | Instalación de las 6 VMs (DC01, APP01, 4 clientes), IPs, hostnames |
| `Capturas y procesos Dia 2.docx` | Completo | 2 | AD DS, DNS (directa + inversa), DHCP (4 scopes), RRAS, Sites, subnetes |
| `capturas y proceso dia 2.5.md` | Completo | 2.5 | Scripts OU/users, unión APP01 + 4 clientes, DHCP leases, RDP |
| `capturas y proceso dia 3.md` | Completo | 3 | 15 GPO, gpresult en 4 sucursales, IIS web, archivos + cuotas, impresión, RDP APP01 |

### Scripts (`05_Scripts/`)

| Archivo | Estado |
|---------|--------|
| `crear_ou_grupos.ps1` | Verificado, 4 UO + 12 grupos |
| `crear_usuarios.ps1` | Verificado, 60 usuarios (5 por grupo) |
| `lista_gpo.md` | Actualizado, 15 GPO en español |
| `templates_web/*.html` + `style.css` | 5 páginas web listas |

### Documentos del informe (`03_Informe/`)

| Archivo | Estado |
|---------|--------|
| `Indicacciones informe.md` | Instrucciones de redacción del usuario |

---

## 2. Hallazgos y correcciones necesarias

### HALLAZGO 1 — `servicios.md`: carpetas por área, no por sucursal (INCONSISTENCIA)

**Problema:** `servicios.md` todavía describe carpetas organizadas por **área** (Recepción, Laboratorio, Administración), pero la estructura AD real es por **sucursal** (UO_SC_Central, UO_SC_Norte, etc.). Las GPO de mapeo del Día 3 (GPO 9-12) usan `\\SRV-APP01\Central`, `\\SRV-APP01\Norte`, etc.

**Acción:** Corregir `servicios.md` para que las carpetas coincidan con lo implementado (por sucursal).

**Evidencia de lo implementado (Día 3):** el .md de capturas del Día 3 muestra carpetas Central, Norte, Este, Sur con permisos NTFS por grupo de sucursal y denegación cruzada. Es correcto.

### HALLAZGO 2 — `servicios.md`: impresoras por área, no por sucursal (INCONSISTENCIA)

**Problema:** `servicios.md` todavía lista `IMP-Recepcion-Central`, `IMP-Laboratorio-Central`, `IMP-Norte`, etc. (mezcla áreas y sucursales). Pero lo implementado en el Día 3 fue 4 impresoras genéricas IBM, una por sucursal (Central, Norte, Este, Sur).

**Acción:** Corregir `servicios.md` para que las impresoras coincidan con lo implementado: 1 por sucursal, driver genérico IBM.

### HALLAZGO 3 — `servicios.md` y `direccionamiento_ip.md`: impresora IP referencial (MENOR)

**Problema:** `direccionamiento_ip.md` lista 5 impresoras con IPs `.30/.31`. Lo implementado usa driver genérico sin puerto TCP/IP real. No es un error, pero la documentación de impresoras en `servicios.md` / `direccionamiento_ip.md` es teórica.

**Acción:** Aclarar que las IPs de impresoras son referenciales para la documentación. Lo implementado usa colas locales en APP01 con driver genérico.

### HALLAZGO 4 — Correo: marcado "omitido" en el Día 3 (PENDIENTE)

**Problema:** En `capturas y proceso dia 3.md`, sección E (Correo) dice "omitido". El checklist Día 3 incluye hMailServer + Thunderbird.

**Acción:** Confirmar con el grupo si el correo se va a implementar en el Día 4 o si se omite definitivamente. El enunciado pide "Servidor de Correo SMTP/POP3". Recomendación fuerte: implementar en el Día 4, es un requisito del enunciado.

### HALLAZGO 5 — GPO 13-15: impresoras por GPO vs. implementación (VERIFICAR)

**Problema:** Las GPO 13-15 despliegan impresoras por sucursal (Norte, Este, Sur). Pero la captura del Día 3 muestra que desde PC-NORTE01 se ven "las 4 impresoras compartidas", no solo la de Norte. Hay que verificar si la GPO de despliegue de impresora funcionó o si simplemente se ven todas porque están compartidas.

**Acción:** Confirmar si las GPO de impresora se configuraron con **Item-Level Targeting** (solo aparece la de la sucursal del usuario) o si aparecen las 4 para todos. Para la defensa, lo ideal es que cada usuario vea solo su impresora.

### HALLAZGO 6 — Topología: 3 sucursales + 1 central (CORRECTO)

**Estado:** La topología muestra 3 sucursales (Norte, Este, Sur) + 1 sede central. Esto es correcto: el enunciado del proyecto maneja 4 "sucursales" como 4 ubicaciones, una de las cuales es la central. Las 4 subredes están presentes, el dominio `mabe.tso1` está correcto.

**Acción:** Ninguna. La topología está correcta.

### HALLAZGO 7 — `Usuarios en cada maquina.md`: usuarios de prueba (USO INFORME)

**Problema:** El archivo lista 4 usuarios de prueba (uno por sucursal). Estos usernames (`ealvarez0`, `crojas0`, `nugartep0`, `stapia4`) no coinciden con los generados automáticamente por `crear_usuarios.ps1` (que usa nombres ficticios como `c-rojas0`, `nugartep0`, etc.).

**Evidencia:** `nugartep0` y `stapia4` parecen estar en el script. `crojas0` coincide con el prefijo `c` de Central. `ealvarez0` coincide con el prefijo `e` de Este.

**Acción:** En el informe, cuando se documenten las pruebas de login, usar los nombres reales del script. El archivo `Usuarios en cada maquina.md` es una ayuda para el demo, perfecta para saber qué usuario loguearse en cada VM cliente.

### HALLAZGO 8 — `direccionamiento_ip.md`: nota crítica de NICs (BIEN DOCUMENTADO)

**Estado:** La nota crítica sobre el orden de NICs VirtualBox vs Windows está bien documentada en el checklist Día 2 y en `direccionamiento_ip.md`. La tabla real de emparejamiento por MAC está en el checklist.

**Acción:** Ninguna. Bien hecho.

### HALLAZGO 9 — `checklist_dia2`: referencias a "SRV-AD01" (TYPO)

**Problema:** En el .docx del Día 2, sección RRAS, dice "SRV-AD01" en lugar de "SRV-DC01".

**Acción:** Corregir en el informe final. El nombre correcto es SRV-DC01.

### HALLAZGO 10 — GPO 7-8: enlazadas a `UO_SC_Central` (VERIFICAR)

**Problema:** Las GPO 7 (Disable Control Panel) y 8 (Disable CMD) están enlazadas a `UO_SC_Central`. La captura del Día 3 muestra la verificación en PC-REC01 (Central) de que el Panel de Control está restringido. Correcto. Pero hay que decidir si esta restricción solo aplica a Central o a todas las sucursales.

**Acción:** Confirmar con el grupo si quieren que las restricciones (CMD, Panel de control) apliquen a todas las sucursales o solo a Central. Si solo a Central, está bien. Si a todas, hay que enlazar las GPO 7-8 a las 4 UO.

---

## 3. Correcciones que voy a aplicar ahora

1. **`servicios.md`**: reescribir la sección de carpetas e impresoras para que coincida con lo implementado (por sucursal, no por área).
2. **`direccionamiento_ip.md`**: aclarar que las IPs de impresoras son referenciales.
3. **Marcar el correo como pendiente** en el estado del proyecto.

## 4. Preguntas para el grupo (antes del Día 4)

1. **Correo:** ¿se implementa en el Día 4 o se omite? (Recomendación: implementarlo, es requisito del enunciado)
2. **GPO impresoras:** ¿aparecen las 4 para todos o solo la de la sucursal del usuario? (Ideal: solo la suya)
3. **GPO 7-8 (CMD/Panel):** ¿solo Central o todas las sucursales?
4. **GPO extra por Sitio:** ¿quieren agregar 2-3 GPO enlazadas por Sitio (SC-Norte, SC-Este, SC-Sur) para enriquecer la defensa?