#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    Crea usuarios de dominio y los agrega a grupos (5 usuarios por grupo).
    4 sucursales x 3 grupos x 5 usuarios = 60 cuentas.
.DESCRIPTION
    Cumple y supera el minimo academico (45). Password inicial de laboratorio.
.NOTES
    Ejecutar en SRV-DC01 como Administrador del dominio, despues de crear_ou_grupos.ps1.
#>

$ErrorActionPreference = 'Stop'
$DomainDN = (Get-ADDomain).DistinguishedName
$UPNSuffix = (Get-ADDomain).DNSRoot   # mabe.tso1

# Password de laboratorio academico
$PlainPassword = 'User#Lab'
$Password = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

# Helper: genera 5 usuarios por grupo con nombres unicos
# Formato SamAccountName: primera letra nombre + apellido + numero de sucursal
function New-UserPlan {
    $plan = @()
    $sucursales = @(
        @{ OU='UO_SC_Central'; Prefix='c'; G1='G_Central_Usuarios'; G2='G_Central_Supervisores'; G3='G_Central_Impresion' },
        @{ OU='UO_SC_Norte';   Prefix='n'; G1='G_Norte_Usuarios';   G2='G_Norte_Supervisores';   G3='G_Norte_Impresion' },
        @{ OU='UO_SC_Este';    Prefix='e'; G1='G_Este_Usuarios';     G2='G_Este_Supervisores';   G3='G_Este_Impresion' },
        @{ OU='UO_SC_Sur';     Prefix='s'; G1='G_Sur_Usuarios';      G2='G_Sur_Supervisores';    G3='G_Sur_Impresion' }
    )

    # Nombres y apuestos ficticios para generar usuarios unicos
    $nombres = @('Ana','Bruno','Carla','Diego','Elena','Felipe','Gabriela','Hugo','Ines','Jorge',
                 'Karina','Luis','Marta','Nicolas','Olga','Pablo','Rosa','Sergio','Tania','Ulises',
                 'Valeria','Walter','Ximena','Yamil','Zulema','Adrian','Belen','Cesar','Diana','Edgar',
                 'Fernanda','Gustavo','Helena','Ivan','Julia','Kevin','Laura','Marco','Nancy','Oscar',
                 'Patricia','Roberto','Sandra','Tomas','Ursula','Vicente','Wendy','Yenny','Zaida','Alvaro',
                 'Beatriz','Carlos','Daniela','Esteban','Fatima')
    $apellidos = @('Rojas','Salas','Mendez','Paredes','Quiroga','Arias','Bustos','Castro','Dorado','Espinoza',
                   'Flores','Guzman','Hinojosa','Ibanez','Jimenez','Klein','Luna','Mora','Nieto','Ortega',
                   'Pinto','Quesada','Rivas','Soto','Torrez','Ugarte','Vargas','Wolf','Yanez','Zambrana',
                   'Alvarez','Benitez','Caceres','Delgado','Estrada','Franco','Garcia','Herrera','Irala','Justiniano',
                   'Krell','Loza','Miranda','Nava','Orellana','Paz','Quispe','Roca','Sandi','Tapia',
                   'Ugarte','Vega','Wyss','Zamora','Antelo')

    $idx = 0
    foreach ($suc in $sucursales) {
        # 5 usuarios para G1 (Usuarios)
        for ($i = 0; $i -lt 5; $i++) {
            $g = $suc.G1
            $sam = "$($suc.Prefix)$($apellidos[$idx % $apellidos.Count])$i"
            $plan += @{
                Given = $nombres[$idx % $nombres.Count]
                Sur   = $apellidos[$idx % $apellidos.Count]
                Sam   = $sam.ToLower()
                OU    = $suc.OU
                Groups = @($g, $suc.G3)
            }
            $idx++
        }
        # 5 usuarios para G2 (Supervisores)
        for ($i = 0; $i -lt 5; $i++) {
            $sam = "$($suc.Prefix)$($apellidos[$idx % $apellidos.Count])s$i"
            $plan += @{
                Given = $nombres[$idx % $nombres.Count]
                Sur   = $apellidos[$idx % $apellidos.Count]
                Sam   = $sam.ToLower()
                OU    = $suc.OU
                Groups = @($suc.G2, $suc.G3)
            }
            $idx++
        }
        # 5 usuarios para G3 (Impresion) dedicados
        for ($i = 0; $i -lt 5; $i++) {
            $sam = "$($suc.Prefix)$($apellidos[$idx % $apellidos.Count])p$i"
            $plan += @{
                Given = $nombres[$idx % $nombres.Count]
                Sur   = $apellidos[$idx % $apellidos.Count]
                Sam   = $sam.ToLower()
                OU    = $suc.OU
                Groups = @($suc.G3)
            }
            $idx++
        }
    }
    return $plan
}

$UserPlan = New-UserPlan

Write-Host '=== Creando usuarios Laboratorio Mabe (4 sucursales) ===' -ForegroundColor Cyan
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
            -Description "Usuario lab Mabe - $($u.OU)"
        Write-Host "[OK] $($u.Sam) ($display)" -ForegroundColor Green
        $created++
    }

    foreach ($grp in $u.Groups) {
        try {
            Add-ADGroupMember -Identity $grp -Members $u.Sam -ErrorAction Stop
        }
        catch {
            # Ya es miembro u otro warning no critico
        }
    }
}

Write-Host '=== Conteo de miembros por grupo ===' -ForegroundColor Cyan
$groupNames = @(
    'G_Central_Usuarios','G_Central_Supervisores','G_Central_Impresion',
    'G_Norte_Usuarios','G_Norte_Supervisores','G_Norte_Impresion',
    'G_Este_Usuarios','G_Este_Supervisores','G_Este_Impresion',
    'G_Sur_Usuarios','G_Sur_Supervisores','G_Sur_Impresion'
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
