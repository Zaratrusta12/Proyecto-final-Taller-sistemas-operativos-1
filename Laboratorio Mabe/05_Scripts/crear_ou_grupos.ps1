#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    Crea UO y grupos de seguridad para Laboratorio Mabe (dominio mabe.tso1).
.NOTES
    Ejecutar en SRV-DC01 como Administrador del dominio.
    Ejemplo:
      Set-ExecutionPolicy Bypass -Scope Process -Force
      .\crear_ou_grupos.ps1
#>

$ErrorActionPreference = 'Stop'
$DomainDN = (Get-ADDomain).DistinguishedName

$OUs = @(
    @{ Name = 'UO_Recepcion';      Path = $DomainDN },
    @{ Name = 'UO_Laboratorio';    Path = $DomainDN },
    @{ Name = 'UO_Administracion'; Path = $DomainDN }
)

$Groups = @(
    # Recepción — 3 grupos
    @{ Name = 'G_Rec_Usuarios';      Sam = 'G_Rec_Usuarios';      OU = 'UO_Recepcion';      Desc = 'Usuarios de recepcion Laboratorio Mabe' },
    @{ Name = 'G_Rec_Supervisores';  Sam = 'G_Rec_Supervisores';  OU = 'UO_Recepcion';      Desc = 'Supervisores de recepcion' },
    @{ Name = 'G_Rec_Impresion';     Sam = 'G_Rec_Impresion';     OU = 'UO_Recepcion';      Desc = 'Permiso impresora recepcion' },

    # Laboratorio — 3 grupos
    @{ Name = 'G_Lab_Analistas';    Sam = 'G_Lab_Analistas';    OU = 'UO_Laboratorio';    Desc = 'Analistas y tecnólogos de laboratorio' },
    @{ Name = 'G_Lab_Jefes';        Sam = 'G_Lab_Jefes';        OU = 'UO_Laboratorio';    Desc = 'Jefatura de laboratorio' },
    @{ Name = 'G_Lab_Impresion';    Sam = 'G_Lab_Impresion';    OU = 'UO_Laboratorio';    Desc = 'Permiso impresora laboratorio' },

    # Administración — 3 grupos
    @{ Name = 'G_Adm_Contabilidad'; Sam = 'G_Adm_Contabilidad'; OU = 'UO_Administracion'; Desc = 'Personal de contabilidad' },
    @{ Name = 'G_Adm_RRHH';         Sam = 'G_Adm_RRHH';         OU = 'UO_Administracion'; Desc = 'Recursos humanos' },
    @{ Name = 'G_Adm_Impresion';    Sam = 'G_Adm_Impresion';    OU = 'UO_Administracion'; Desc = 'Permiso impresora administracion' }
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
