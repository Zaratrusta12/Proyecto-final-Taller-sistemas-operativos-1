# Catálogo de 15 GPO — Laboratorio Mabe

Ejecutar creación desde **SRV-DC01** con *Group Policy Management* (gpmc.msc).  
Cada GPO debe tener **al menos un setting real** (no dejar vacías).

Password de referencia lab: ver README.

---

## Tabla maestra

| # | Nombre GPO | Enlazar a | Configuración mínima (ruta GPMC) |
|---|------------|-----------|----------------------------------|
| 1 | `GPO_PasswordPolicy` | Dominio `mabe.tso1` | Computer Config → Policies → Windows Settings → Security Settings → Account Policies → Password Policy: mín. 8 caracteres, complejidad habilitada, historial 5, máx. edad 90 días |
| 2 | `GPO_AccountLockout` | Dominio `mabe.tso1` | Account Policies → Account Lockout: 5 intentos, duración 30 min, reset contador 30 min |
| 3 | `GPO_ScreenLock` | Dominio `mabe.tso1` | User Config → Policies → Admin Templates → Control Panel → Personalization: Screen saver timeout 300, password on resume Enabled |
| 4 | `GPO_Restrict_USB` | Dominio o UOs de usuarios | Computer Config → Admin Templates → System → Removable Storage Access: Removable Disks Deny write = Enabled |
| 5 | `GPO_WindowsUpdate` | Dominio (equipos) | Computer Config → Admin Templates → Windows Components → Windows Update: configurar política de actualización automática (ej. auto download + notify) |
| 6 | `GPO_Firewall_Baseline` | Dominio (equipos) | Computer Config → Windows Settings → Security Settings → Windows Defender Firewall: Domain Profile ON |
| 7 | `GPO_Disable_ControlPanel` | `UO_Recepcion` | User Config → Admin Templates → Control Panel: Prohibit access to Control Panel and PC settings = Enabled |
| 8 | `GPO_Disable_CMD` | `UO_Recepcion` | User Config → Admin Templates → System: Prevent access to the command prompt = Enabled |
| 9 | `GPO_Map_Drive_Recepcion` | `UO_Recepcion` | User Config → Preferences → Windows Settings → Drive Maps: `R:` → `\\SRV-APP01\Recepcion` |
| 10 | `GPO_Map_Drive_Lab` | `UO_Laboratorio` | Drive Maps: `L:` → `\\SRV-APP01\Laboratorio` |
| 11 | `GPO_Map_Drive_Admin` | `UO_Administracion` | Drive Maps: `A:` → `\\SRV-APP01\Administracion` |
| 12 | `GPO_Deploy_Printer_Rec` | `UO_Recepcion` | User Config → Preferences → Control Panel Settings → Printers: compartir `\\SRV-APP01\IMP-Recepcion` |
| 13 | `GPO_Deploy_Printer_Lab` | `UO_Laboratorio` | Printer `\\SRV-APP01\IMP-Laboratorio` |
| 14 | `GPO_Deploy_Printer_Admin` | `UO_Administracion` | Printer `\\SRV-APP01\IMP-Administracion` |
| 15 | `GPO_Desktop_Info` | Dominio (usuarios) | User Config → Admin Templates → Desktop: Remove Recycle Bin icon from desktop = Enabled **o** Wallpaper corporativo si tienen imagen |

## GPO de reserva (si piden más o alguna falla)

| # | Nombre | Idea |
|---|--------|------|
| 16 | `GPO_No_Run` | Quitar Ejecutar del menú inicio (recepción) |
| 17 | `GPO_IE_Restrictions` | Restringir opciones de Internet Explorer/Edge básicas |
| 18 | `GPO_Logon_Message` | Mensaje legal al inicio de sesión (aviso datos clínicos) |

## Script opcional de creación de objetos GPO vacíos

En PowerShell (DC), solo crea el objeto; la configuración se hace en GPMC:

```powershell
$gpos = @(
  'GPO_PasswordPolicy','GPO_AccountLockout','GPO_ScreenLock','GPO_Restrict_USB',
  'GPO_WindowsUpdate','GPO_Firewall_Baseline','GPO_Disable_ControlPanel','GPO_Disable_CMD',
  'GPO_Map_Drive_Recepcion','GPO_Map_Drive_Lab','GPO_Map_Drive_Admin',
  'GPO_Deploy_Printer_Rec','GPO_Deploy_Printer_Lab','GPO_Deploy_Printer_Admin',
  'GPO_Desktop_Info'
)
foreach ($n in $gpos) {
  if (-not (Get-GPO -Name $n -ErrorAction SilentlyContinue)) {
    New-GPO -Name $n | Out-Null
    Write-Host "Creada: $n"
  }
}
```

## Verificación en cliente

```cmd
gpupdate /force
gpresult /r
gpresult /h C:\Temp\gpresult_mabe.html
```

Capturar: GPMC con las 15 GPO, enlace a UO/dominio, y `gpresult` en `PC-REC01`.

## Orden práctico de implementación

1. Primero GPO 1 y 2 (password/lockout) a nivel dominio.
2. Crear shares e impresoras en APP01.
3. Luego GPO de mapeo e impresoras (9–14).
4. Restricciones de recepción (7–8) y resto.
5. Probar con un usuario de cada UO.
