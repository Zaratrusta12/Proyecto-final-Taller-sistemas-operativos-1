#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    Crea UO y grupos de seguridad para Laboratorio Mabe (4 sucursales).
    Estructura: 4 UO (una por sucursal) x 3 grupos por UO = 12 grupos.
.NOTES
    Ejecutar en SRV-DC01 como Administrador del dominio, despues de promover AD.
    Ejemplo:
      Set-ExecutionPolicy Bypass -Scope Process -Force
      .\crear_ou_grupos.ps1
#>

$ErrorActionPreference = 'Stop'
$DomainDN = (Get-ADDomain).DistinguishedName

# 4 UO, una por sucursal
$OUs = @(
    @{ Name = 'UO_SC_Central'; Path = $DomainDN },
    @{ Name = 'UO_SC_Norte';   Path = $DomainDN },
    @{ Name = 'UO_SC_Este';    Path = $DomainDN },
    @{ Name = 'UO_SC_Sur';     Path = $DomainDN }
)

# 3 grupos por UO = 12 total
$Groups = @(
    # Central
    @{ Name = 'G_Central_Usuarios';      Sam = 'G_Central_Usuarios';      OU = 'UO_SC_Central'; Desc = 'Usuarios sucursal Central' },
    @{ Name = 'G_Central_Supervisores';  Sam = 'G_Central_Supervisores';  OU = 'UO_SC_Central'; Desc = 'Supervisores sucursal Central' },
    @{ Name = 'G_Central_Impresion';     Sam = 'G_Central_Impresion';     OU = 'UO_SC_Central'; Desc = 'Impresion sucursal Central' },
    # Norte
    @{ Name = 'G_Norte_Usuarios';       Sam = 'G_Norte_Usuarios';        OU = 'UO_SC_Norte';   Desc = 'Usuarios sucursal Norte' },
    @{ Name = 'G_Norte_Supervisores';   Sam = 'G_Norte_Supervisores';   OU = 'UO_SC_Norte';   Desc = 'Supervisores sucursal Norte' },
    @{ Name = 'G_Norte_Impresion';      Sam = 'G_Norte_Impresion';       OU = 'UO_SC_Norte';   Desc = 'Impresion sucursal Norte' },
    # Este
    @{ Name = 'G_Este_Usuarios';        Sam = 'G_Este_Usuarios';         OU = 'UO_SC_Este';    Desc = 'Usuarios sucursal Este' },
    @{ Name = 'G_Este_Supervisores';    Sam = 'G_Este_Supervisores';     OU = 'UO_SC_Este';    Desc = 'Supervisores sucursal Este' },
    @{ Name = 'G_Este_Impresion';       Sam = 'G_Este_Impresion';        OU = 'UO_SC_Este';    Desc = 'Impresion sucursal Este' },
    # Sur
    @{ Name = 'G_Sur_Usuarios';         Sam = 'G_Sur_Usuarios';          OU = 'UO_SC_Sur';     Desc = 'Usuarios sucursal Sur' },
    @{ Name = 'G_Sur_Supervisores';     Sam = 'G_Sur_Supervisores';      OU = 'UO_SC_Sur';     Desc = 'Supervisores sucursal Sur' },
    @{ Name = 'G_Sur_Impresion';        Sam = 'G_Sur_Impresion';         OU = 'UO_SC_Sur';     Desc = 'Impresion sucursal Sur' }
)

Write-Host '=== Creando Unidades Organizativas ===' -ForegroundColor Cyan
foreach ($ou in $OUs) {
    $existing = Get-ADOrganizationalUnit -Filter "Name -eq '$($ou.Name)'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[SKIP] OU ya existe: $($ou.Name)" -ForegroundColor Yellow
    }
    else {
        New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path -ProtectedFromAccidentalDeletion $true
        Write-Host "[OK] OU creada: $($ou.Name)" -ForegroundColor Green
    }
}

Write-Host '=== Creando Grupos de seguridad ===' -ForegroundColor Cyan
foreach ($g in $Groups) {
    $ouDn = "OU=$($g.OU),$DomainDN"
    $existing = Get-ADGroup -Filter "SamAccountName -eq '$($g.Sam)'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[SKIP] Grupo ya existe: $($g.Name)" -ForegroundColor Yellow
    }
    else {
        New-ADGroup -Name $g.Name `
            -SamAccountName $g.Sam `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $ouDn `
            -Description $g.Desc
        Write-Host "[OK] Grupo creado: $($g.Name) en $($g.OU)" -ForegroundColor Green
    }
}

Write-Host '=== Resumen ===' -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter "Name -like 'UO_*'" | Select-Object Name, DistinguishedName | Format-Table -AutoSize
Get-ADGroup -Filter "Name -like 'G_*'" | Select-Object Name, SamAccountName, DistinguishedName | Format-Table -AutoSize
Write-Host 'Listo. Continuar con crear_usuarios.ps1' -ForegroundColor Green
