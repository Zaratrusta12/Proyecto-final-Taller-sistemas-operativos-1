#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    Crea usuarios de dominio y los agrega a grupos (5 usuarios por grupo).
.DESCRIPTION
    Cumple el mínimo académico: 3 UO x 3 grupos x 5 usuarios = 45 cuentas.
    Password inicial uniforme de laboratorio (cambiar en producción real).
.NOTES
    Ejecutar en SRV-DC01 como Administrador del dominio, después de crear_ou_grupos.ps1.
#>

$ErrorActionPreference = 'Stop'
$DomainDN = (Get-ADDomain).DistinguishedName
$UPNSuffix = (Get-ADDomain).DNSRoot   # mabe.tso1

# Password de laboratorio académico
$PlainPassword = 'User#Lab'
$Password = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

# Definición: cada grupo con exactamente 5 usuarios únicos
$UserPlan = @(
    # --- UO_Recepcion / G_Rec_Usuarios ---
    @{ Given='Ana';     Sur='Rojas';      Sam='a.rojas';      OU='UO_Recepcion';      Groups=@('G_Rec_Usuarios','G_Rec_Impresion') },
    @{ Given='Bruno';   Sur='Salas';      Sam='b.salas';      OU='UO_Recepcion';      Groups=@('G_Rec_Usuarios','G_Rec_Impresion') },
    @{ Given='Carla';   Sur='Mendez';     Sam='c.mendez';     OU='UO_Recepcion';      Groups=@('G_Rec_Usuarios','G_Rec_Impresion') },
    @{ Given='Diego';   Sur='Paredes';    Sam='d.paredes';    OU='UO_Recepcion';      Groups=@('G_Rec_Usuarios','G_Rec_Impresion') },
    @{ Given='Elena';   Sur='Quiroga';    Sam='e.quiroga';    OU='UO_Recepcion';      Groups=@('G_Rec_Usuarios','G_Rec_Impresion') },

    # --- UO_Recepcion / G_Rec_Supervisores ---
    @{ Given='Felipe';  Sur='Arias';      Sam='f.arias';      OU='UO_Recepcion';      Groups=@('G_Rec_Supervisores','G_Rec_Impresion') },
    @{ Given='Gabriela';Sur='Bustos';     Sam='g.bustos';     OU='UO_Recepcion';      Groups=@('G_Rec_Supervisores','G_Rec_Impresion') },
    @{ Given='Hugo';    Sur='Castro';     Sam='h.castro';     OU='UO_Recepcion';      Groups=@('G_Rec_Supervisores','G_Rec_Impresion') },
    @{ Given='Ines';    Sur='Dorado';     Sam='i.dorado';     OU='UO_Recepcion';      Groups=@('G_Rec_Supervisores','G_Rec_Impresion') },
    @{ Given='Jorge';   Sur='Espinoza';   Sam='j.espinoza';   OU='UO_Recepcion';      Groups=@('G_Rec_Supervisores','G_Rec_Impresion') },

    # --- usuarios extra solo en G_Rec_Impresion para completar 5 "propios" si se audita por grupo primario ---
    # (Los 10 de arriba ya cubren Impresion por membresía múltiple.
    #  Se agregan 5 dedicados a impresión recepción para conteo limpio si el docente lista miembros del grupo.)
    @{ Given='Karina';  Sur='Flores';     Sam='k.flores';     OU='UO_Recepcion';      Groups=@('G_Rec_Impresion') },
    @{ Given='Luis';    Sur='Guzman';     Sam='l.guzman';     OU='UO_Recepcion';      Groups=@('G_Rec_Impresion') },
    @{ Given='Marta';   Sur='Hinojosa';   Sam='m.hinojosa';   OU='UO_Recepcion';      Groups=@('G_Rec_Impresion') },
    @{ Given='Nicolas'; Sur='Ibanez';     Sam='n.ibanez';     OU='UO_Recepcion';      Groups=@('G_Rec_Impresion') },
    @{ Given='Olga';    Sur='Jimenez';    Sam='o.jimenez';    OU='UO_Recepcion';      Groups=@('G_Rec_Impresion') },

    # --- UO_Laboratorio / G_Lab_Analistas ---
    @{ Given='Pablo';   Sur='Klein';      Sam='p.klein';      OU='UO_Laboratorio';    Groups=@('G_Lab_Analistas','G_Lab_Impresion') },
    @{ Given='Rosa';    Sur='Luna';       Sam='r.luna';       OU='UO_Laboratorio';    Groups=@('G_Lab_Analistas','G_Lab_Impresion') },
    @{ Given='Sergio';  Sur='Mora';       Sam='s.mora';       OU='UO_Laboratorio';    Groups=@('G_Lab_Analistas','G_Lab_Impresion') },
    @{ Given='Tania';   Sur='Nieto';      Sam='t.nieto';      OU='UO_Laboratorio';    Groups=@('G_Lab_Analistas','G_Lab_Impresion') },
    @{ Given='Ulises';  Sur='Ortega';     Sam='u.ortega';     OU='UO_Laboratorio';    Groups=@('G_Lab_Analistas','G_Lab_Impresion') },

    # --- UO_Laboratorio / G_Lab_Jefes ---
    @{ Given='Valeria'; Sur='Pinto';      Sam='v.pinto';      OU='UO_Laboratorio';    Groups=@('G_Lab_Jefes','G_Lab_Impresion') },
    @{ Given='Walter';  Sur='Quesada';    Sam='w.quesada';    OU='UO_Laboratorio';    Groups=@('G_Lab_Jefes','G_Lab_Impresion') },
    @{ Given='Ximena';  Sur='Rivas';      Sam='x.rivas';      OU='UO_Laboratorio';    Groups=@('G_Lab_Jefes','G_Lab_Impresion') },
    @{ Given='Yamil';   Sur='Soto';       Sam='y.soto';       OU='UO_Laboratorio';    Groups=@('G_Lab_Jefes','G_Lab_Impresion') },
    @{ Given='Zulema';  Sur='Torrez';     Sam='z.torrez';     OU='UO_Laboratorio';    Groups=@('G_Lab_Jefes','G_Lab_Impresion') },

    # --- G_Lab_Impresion dedicados ---
    @{ Given='Adrian';  Sur='Ugarte';     Sam='ad.ugarte';    OU='UO_Laboratorio';    Groups=@('G_Lab_Impresion') },
    @{ Given='Belen';   Sur='Vargas';     Sam='be.vargas';    OU='UO_Laboratorio';    Groups=@('G_Lab_Impresion') },
    @{ Given='Cesar';   Sur='Wolf';       Sam='ce.wolf';      OU='UO_Laboratorio';    Groups=@('G_Lab_Impresion') },
    @{ Given='Diana';   Sur='Yanez';      Sam='di.yanez';     OU='UO_Laboratorio';    Groups=@('G_Lab_Impresion') },
    @{ Given='Edgar';   Sur='Zambrana';   Sam='ed.zambrana';  OU='UO_Laboratorio';    Groups=@('G_Lab_Impresion') },

    # --- UO_Administracion / G_Adm_Contabilidad ---
    @{ Given='Fernanda';Sur='Alvarez';    Sam='fe.alvarez';   OU='UO_Administracion'; Groups=@('G_Adm_Contabilidad','G_Adm_Impresion') },
    @{ Given='Gustavo'; Sur='Benitez';    Sam='gu.benitez';   OU='UO_Administracion'; Groups=@('G_Adm_Contabilidad','G_Adm_Impresion') },
    @{ Given='Helena';  Sur='Caceres';    Sam='he.caceres';   OU='UO_Administracion'; Groups=@('G_Adm_Contabilidad','G_Adm_Impresion') },
    @{ Given='Ivan';    Sur='Delgado';    Sam='iv.delgado';   OU='UO_Administracion'; Groups=@('G_Adm_Contabilidad','G_Adm_Impresion') },
    @{ Given='Julia';   Sur='Estrada';    Sam='ju.estrada';   OU='UO_Administracion'; Groups=@('G_Adm_Contabilidad','G_Adm_Impresion') },

    # --- UO_Administracion / G_Adm_RRHH ---
    @{ Given='Kevin';   Sur='Franco';     Sam='ke.franco';    OU='UO_Administracion'; Groups=@('G_Adm_RRHH','G_Adm_Impresion') },
    @{ Given='Laura';   Sur='Garcia';     Sam='la.garcia';    OU='UO_Administracion'; Groups=@('G_Adm_RRHH','G_Adm_Impresion') },
    @{ Given='Marco';   Sur='Herrera';    Sam='ma.herrera';   OU='UO_Administracion'; Groups=@('G_Adm_RRHH','G_Adm_Impresion') },
    @{ Given='Nancy';   Sur='Irala';      Sam='na.irala';     OU='UO_Administracion'; Groups=@('G_Adm_RRHH','G_Adm_Impresion') },
    @{ Given='Oscar';   Sur='Justiniano'; Sam='os.justiniano'; OU='UO_Administracion'; Groups=@('G_Adm_RRHH','G_Adm_Impresion') },

    # --- G_Adm_Impresion dedicados ---
    @{ Given='Patricia';Sur='Krell';      Sam='pa.krell';     OU='UO_Administracion'; Groups=@('G_Adm_Impresion') },
    @{ Given='Roberto'; Sur='Loza';       Sam='ro.loza';      OU='UO_Administracion'; Groups=@('G_Adm_Impresion') },
    @{ Given='Sandra';  Sur='Miranda';    Sam='sa.miranda';   OU='UO_Administracion'; Groups=@('G_Adm_Impresion') },
    @{ Given='Tomas';   Sur='Nava';       Sam='to.nava';      OU='UO_Administracion'; Groups=@('G_Adm_Impresion') },
    @{ Given='Ursula';  Sur='Orellana';   Sam='ur.orellana';  OU='UO_Administracion'; Groups=@('G_Adm_Impresion') }
)

Write-Host '=== Creando usuarios Laboratorio Mabe ===' -ForegroundColor Cyan
$created = 0
$skipped = 0

foreach ($u in $UserPlan) {
    $ouPath = "OU=$($u.OU),$DomainDN"
    $upn = "$($u.Sam)@$UPNSuffix"
    $display = "$($u.Given) $($u.Sur)"

    $exists = Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue
    if ($exists) {
        Write-Host "[SKIP] $($u.Sam)" -ForegroundColor Yellow
        $skipped++
    }
    else {
        New-ADUser -Name $display `
            -GivenName $u.Given `
            -Surname $u.Sur `
            -SamAccountName $u.Sam `
            -UserPrincipalName $upn `
            -Path $ouPath `
            -AccountPassword $Password `
            -ChangePasswordAtLogon $false `
            -Enabled $true `
            -Description "Usuario lab academico Mabe - $($u.OU)"
        Write-Host "[OK] $($u.Sam) ($display)" -ForegroundColor Green
        $created++
    }

    foreach ($grp in $u.Groups) {
        try {
            Add-ADGroupMember -Identity $grp -Members $u.Sam -ErrorAction Stop
        }
        catch {
            # Ya es miembro u otro warning no crítico
        }
    }
}

Write-Host '=== Conteo de miembros por grupo ===' -ForegroundColor Cyan
$groupNames = @(
    'G_Rec_Usuarios','G_Rec_Supervisores','G_Rec_Impresion',
    'G_Lab_Analistas','G_Lab_Jefes','G_Lab_Impresion',
    'G_Adm_Contabilidad','G_Adm_RRHH','G_Adm_Impresion'
)
foreach ($gn in $groupNames) {
    $count = @(Get-ADGroupMember -Identity $gn -ErrorAction SilentlyContinue).Count
    $flag = if ($count -ge 5) { 'OK' } else { 'FALTA' }
    Write-Host ("[{0}] {1}: {2} miembros" -f $flag, $gn, $count)
}

Write-Host ""
Write-Host "Creados: $created | Omitidos: $skipped" -ForegroundColor Cyan
Write-Host "Password inicial de lab: $PlainPassword" -ForegroundColor Magenta
Write-Host 'Listo.' -ForegroundColor Green
