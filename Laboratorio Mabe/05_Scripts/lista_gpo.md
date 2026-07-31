# Catálogo de 15 GPO — Laboratorio Mabe (4 sucursales)

Crear desde **SRV-DC01** con *Administrador de directivas de grupo* (`gpmc.msc`).
Cada GPO debe tener **al menos un parámetro real** (no dejar vacías).

Password de referencia lab: ver README.

---

## Tabla maestra

| # | Nombre GPO | Enlazar a | Configuración mínima (ruta GPMC en español) |
|---|------------|-----------|---------------------------------------------|
| 1 | `GPO_PasswordPolicy` | Dominio `mabe.tso1` | Configuración de equipo → Directivas → Configuración de Windows → Configuración de seguridad → Directivas de cuenta → Directiva de contraseñas: mín. 8 caracteres, complejidad habilitada, historial 5, máx. edad 90 días |
| 2 | `GPO_AccountLockout` | Dominio `mabe.tso1` | Configuración de equipo → Directivas → Configuración de Windows → Configuración de seguridad → Directivas de cuenta → Directiva de bloqueo de cuentas: 5 intentos, duración 30 min, reset contador 30 min |
| 3 | `GPO_ScreenLock` | Dominio `mabe.tso1` | Configuración de usuario → Directivas → Plantillas administrativas → Panel de control → Personalización: Tempo de espera del protector de pantalla 300, Exigir contraseña al reanudar = Habilitado |
| 4 | `GPO_Restrict_USB` | Dominio o UOs | Configuración de equipo → Plantillas administrativas → Sistema → Acceso a almacenamiento extraíble: Denegar escritura en discos extraíbles = Habilitado |
| 5 | `GPO_WindowsUpdate` | Dominio (equipos) | Configuración de equipo → Plantillas administrativas → Componentes de Windows → Windows Update: Configurar actualizaciones automáticas = Habilitado, opción 4 (descargar y notificar) |
| 6 | `GPO_Firewall_Baseline` | Dominio (equipos) | Configuración de equipo → Configuración de Windows → Configuración de seguridad → Firewall de Windows Defender: Perfil de dominio = Habilitado |
| 7 | `GPO_Disable_ControlPanel` | `UO_SC_Central` | Configuración de usuario → Plantillas administrativas → Panel de control: Impedir el acceso a las opciones de Panel de control y PC Settings = Habilitado |
| 8 | `GPO_Disable_CMD` | `UO_SC_Central` | Configuración de usuario → Plantillas administrativas → Sistema: Impedir el acceso al símbolo del sistema = Habilitado |
| 9 | `GPO_Map_Drive_Central` | `UO_SC_Central` | Configuración de usuario → Preferencias → Configuración de Windows → Unidades asignadas: `R:` → `\\SRV-APP01\Central` |
| 10 | `GPO_Map_Drive_Norte` | `UO_SC_Norte` | `S:` → `\\SRV-APP01\Norte` |
| 11 | `GPO_Map_Drive_Este` | `UO_SC_Este` | `S:` → `\\SRV-APP01\Este` |
| 12 | `GPO_Map_Drive_Sur` | `UO_SC_Sur` | `S:` → `\\SRV-APP01\Sur` |
| 13 | `GPO_Deploy_Printer_Norte` | `UO_SC_Norte` | Configuración de usuario → Preferencias → Configuración del Panel de control → Impresoras: `\\SRV-APP01\IMP-Norte` |
| 14 | `GPO_Deploy_Printer_Este` | `UO_SC_Este` | `\\SRV-APP01\IMP-Este` |
| 15 | `GPO_Deploy_Printer_Sur` | `UO_SC_Sur` | `\\SRV-APP01\IMP-Sur` |
| 16 | `GPO_Descripcion_Message` | Sitio `SC-Central` | Configuración de equipo → Configuración de Windows → Directivas de extremos seguros → Mensaje de inicio de sesión: "Uso restringido a personal autorizado de Laboratorio Mabe" |
| 16 | `GPO_Restrict_USB_West` | Sitio `SC-Norte` | Igual que #4 pero a nivel de sitio (ejemplo de GPO por sitio) |
| 16 | `GPO_ScreenLock_Sur` | Sitio `SC-Sur` | Protector de pantalla más agresivo (120 seg) para la sucursal sur |

> Las GPO 16 son de reserva/extra si piden más o alguna falla. Con las 15 primeras sobra al enunciado.

### Patrón de enlace de GPO

| Nivel | GPO que aplicar |
|-------|----------------|
| **Dominio** (a todos) | Password (1), Lockout (2), ScreenLock (3), USB (4), WindowsUpdate (5), Firewall (6) |
| **Por UO/sucursal** | Map drive (9-12), Impresora (13-15), Control panel (7), CMD (8) |
| **Por Sitio** (opcional, para enriquecer) | Message (16), USBRestrict por sitio, ScreenLock por sitio |

---

## Script: crear objetos GPO vacíos (opcional, ahorra tiempo)

```powershell
$gpos = @(
  'GPO_PasswordPolicy','GPO_AccountLockout','GPO_ScreenLock','GPO_Restrict_USB',
  'GPO_WindowsUpdate','GPO_Firewall_Baseline','GPO_Disable_ControlPanel','GPO_Disable_CMD',
  'GPO_Map_Drive_Central','GPO_Map_Drive_Norte','GPO_Map_Drive_Este','GPO_Map_Drive_Sur',
  'GPO_Deploy_Printer_Norte','GPO_Deploy_Printer_Este','GPO_Deploy_Printer_Sur'
)
foreach ($n in $gpos) {
  if (-not (Get-GPO -Name $n -ErrorAction SilentlyContinue)) {
    New-GPO -Name $n | Out-Null
    Write-Host "Creada: $n"
  } else {
    Write-Host "Ya existe: $n"
  }
}
```

> Después se enlazan y configuran con GUI en `gpmc.msc`. Es más rápido y seguro que escribir cada setting desde PowerShell.

---

## Verificación en cliente

```cmd
gpupdate /force
gpresult /r
gpresult /h C:\Temp\gpresult_mabe.html
```

Capturar: GPMC con las 15 GPO, enlace a UO/dominio/sitio, y `gpresult` en `PC-REC01` y al menos 1 cliente de otra sucursal.

---

## Orden práctico de implementación

1. Primero GPO 1 y 2 (password/lockout) a nivel dominio.
2. Crear shares e impresoras en APP01 (Día 3).
3. Luego GPO de mapeo e impresoras (9-15).
4. Restricciones de sucursal (7-8 si se enlazan a una UO específica).
5. Probar con un usuario de cada sucursal (en total 4 pruebas).
6. Si sobra tiempo: experimentar con GPO extras (16+) para enriquecer la defensa.

---

## Para el informe

- **Tabla de las 15 GPO** con su nombre, enlace y función.
- **Captura** de GPMC con el árbol de GPO y los enlaces.
- **Captura** de `gpresult /r` mostrando GPO aplicadas en un cliente.
- **Párrafo** justificando el diseño: seguridad base a nivel dominio + parametrización por sucursal (UO y/o Sitio).
- **Mención** de que algunas GPO se enlazan por Sitio (AD Sites) para reforzar el diseño multi-sucursal.