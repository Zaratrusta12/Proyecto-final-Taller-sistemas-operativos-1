# Proyecto Final — Laboratorio Mabe

**Asignatura:** SIS-0210 Taller de Sistemas Operativos I  
**Docente:** Ing. Alex Escobar Peralta  
**Institución:** UPDS — Santa Cruz  
**Entrega:** 31 de julio de 2026  
**Archivo RAR:** `[Grupo # - Laboratorio Mabe].RAR` *(completar número de grupo)*

---

## Integrantes

| # | Nombre |
|---|--------|
| 1 | Luis Miguel Barba Vaca |
| 2 | Julio Fernando Patti Gutierrez |
| 3 | Dennis Gutierrez Tolares |
| 4 | Samuel Falon Toro |
| 5 | Jomar Ariel Ortiz Aguanta |

---

## Empresa

**Laboratorio Mabe** — laboratorio de análisis clínicos con sede en Santa Cruz de la Sierra.  
Proyecto socioformativo: infraestructura Windows Server para continuidad operativa, control centralizado y seguridad.

---

## Decisiones técnicas

| Ítem | Valor |
|------|--------|
| Hipervisor host | VirtualBox |
| SO servidores | **Windows Server 2025 Standard** (Experiencia de Escritorio) — autorizado en clases |
| SO cliente | Windows 10/11 Pro |
| Dominio AD | `mabe.tso1` |
| NETBIOS | `MABE` |
| Topología | draw.io |
| Correo | hMailServer (SMTP/POP3/IMAP local) |
| Red VirtualBox | Internal Network `intnet-mabe` |

### Hosts e IPs

| Equipo | Hostname | IP | Rol principal |
|--------|----------|-----|----------------|
| SERVER1 | `SRV-DC01` | `192.168.10.10` | AD DS, DNS, DHCP, GPO |
| SERVER2 | `SRV-APP01` | `192.168.10.20` | IIS, Archivos, Impresión, Correo |
| Cliente | `PC-REC01` | DHCP | Pruebas y validación |
| Red | — | `192.168.10.0/24` | LAN laboratorio |
| DHCP pool | — | `.100` – `.200` | Clientes |
| Exclusión DHCP | — | `.1` – `.50` | Servidores / red |

---

## Credenciales de laboratorio (solo entorno académico local)

> No usar contraseñas reales de producción. Cambiar si se expone la máquina.

| Cuenta | Uso | Password real del grupo |
|--------|-----|-------------------|
| Administrador local / Domain Admin | Setup y administración | `Admin#Lab2025` |
| Usuarios de dominio | Pruebas de cliente/GPO | `User#Lab` |

---

## Estructura de carpetas

```
Laboratorio Mabe/
├── 01_Diseno/           → empresa, IP, topología, servicios
├── 02_Implementacion/   → capturas por servicio
├── 03_Informe/          → borrador y fuentes
├── 04_Presentacion/     → PPT/Canva
├── 05_Scripts/          → PowerShell altas AD
└── README_PROYECTO.md   → este archivo
```

---

## Estado del proyecto

| Fase | Estado | Notas |
|------|--------|-------|
| 0 Organización | Hecho | Carpetas + docs base |
| 1 Diseño | Hecho (ajustar detalle) | Topología draw.io revisada |
| 2 VMs base | Hecho | 3 VMs, ping DC↔APP OK |
| 3 SERVER1 | En curso | AD/DNS/DHCP/GPO |
| 4 SERVER2 | Pendiente | IIS/Archivos/Impresión/Correo |
| 5 Seguridad + Hyper-V + Backup | Pendiente | |
| 6 Pruebas | Pendiente | |
| 7 Informe | Pendiente | ≥25 páginas APA 7 |
| 8 PPT + RAR | Pendiente | |

---

## Orden de implementación (no saltar)

1. Red VirtualBox `intnet-mabe`
2. Instalar `SRV-DC01` → IP estática `.10`
3. Instalar `SRV-APP01` → IP `.20`, DNS `.10`
4. Instalar `PC-REC01`
5. Promover AD DS dominio `mabe.tso1`
6. DNS + DHCP (con exclusión)
7. Scripts OU/grupos/usuarios
8. Unir APP01 y cliente al dominio
9. 15 GPO
10. IIS (5 páginas), archivos, cuotas, impresión, correo, RDP
11. Seguridad, Hyper-V nested, Backup
12. Pruebas + capturas
13. Informe + presentación

---

## Snapshots recomendados en VirtualBox

| Nombre | Cuándo |
|--------|--------|
| `00_SO_limpio` | Tras instalar SO en cada VM |
| `01_AD_OK` | DC promovido + DNS OK |
| `02_DHCP_CLIENT_OK` | Cliente con IP del pool y en dominio |
| `03_GPO_OK` | 15 GPO aplicadas |
| `04_SERVICIOS_OK` | IIS + files + print + mail |
| `05_PRE_DEMO` | Antes de la defensa |

---

## Referencias rápidas del plan completo

Ver: `.hermes/plans/2026-07-27_103959-proyecto-final-laboratorio-mabe.md`
