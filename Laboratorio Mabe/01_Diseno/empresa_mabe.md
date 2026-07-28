# Ficha de la empresa — Laboratorio Mabe (4 sucursales)

## 1. Datos generales

| Campo | Detalle |
|-------|---------|
| Nombre | Laboratorio Mabe |
| Rubro | Análisis clínicos y diagnóstico de laboratorio |
| Ubicación matriz | Santa Cruz de la Sierra, Bolivia |
| Tipo | PyME de servicios de salud |
| Tamaño simulado | Aprox. 120 colaboradores distribuidos en 4 sucursales |
| Áreas principales | Recepción, Laboratorio (analistas), Administración, Sistemas |

## 2. Descripción

Laboratorio Mabe es un laboratorio de análisis clínicos que atiende pacientes particulares y convenios con seguros y clínicas de la ciudad. Cuenta con cuatro sucursales en la región cruceña: una sede central en Santa Cruz de la Sierra y tres sucursales operativas en zonas Norte, Este y Sur (Cota Brus). Su operación diaria depende de la recepción de muestras, el procesamiento en área técnica, la emisión de resultados y la gestión administrativa (facturación, compras y recursos humanos).

En el escenario del proyecto, la organización opera con equipos en grupo de trabajo, direcciones IP asignadas de forma manual, carpetas compartidas sin control centralizado y sin políticas de seguridad homogéneas. Cada sucursal funciona de forma aislada, lo que complica la administración de usuarios y el acceso a servicios compartidos.

## 3. Problemática de TI (alineada al enunciado)

En Santa Cruz, empresas de servicios como Laboratorio Mabe sufren interrupciones en sus plataformas digitales por configuraciones deficientes en la infraestructura local. En este caso se identifican:

- Pérdidas de tiempo operativo por fallas de red y cuentas locales dispersas en cada sucursal.
- Vulnerabilidades de seguridad al no existir control centralizado de usuarios ni políticas de contraseñas.
- Lentitud y desorden al compartir archivos clínicos y administrativos sin permisos por área ni por sucursal.
- Ausencia de un plan formal de respaldo y recuperación ante fallos.
- Falta de servicios internos básicos: DNS/DHCP corporativo, web institucional, impresión centralizada y correo interno.
- Las sucursales no pueden acceder a los servicios centrales (web, archivos, impresión, correo) por falta de enrutamiento entre subredes.

## 4. Necesidades de TI del proyecto

1. **Identidad centralizada** con Active Directory (`mabe.tso1`) y 4 sitios AD (uno por sucursal).
2. **Red automática** con DHCP central entregando IPs en las 4 subredes (4 scopes con exclusión).
3. **Resolución de nombres** con DNS interno.
4. **Enrutamiento inter-VLAN** con RRAS en el DC para que las sucursales accedan a los servicios centrales.
5. **Sitio web corporativo** (IIS) con información institucional y datos de las 4 sucursales.
6. **Servidor de archivos** con permisos por área y cuotas de disco.
7. **Impresión centralizada** (al menos una impresora por sucursal).
8. **Correo interno** para coordinación entre áreas y sucursales.
9. **Acceso remoto** (RDP) restringido a administración.
10. **Políticas de grupo (GPO)** para estandarizar y asegurar estaciones en todas las sucursales.
11. **Virtualización (Hyper-V)**, **firewall**, **backup** y plan de contingencia.
12. **Enfoque ético:** protección de datos de pacientes con cuentas nominativas, menor privilegio y evidencias de acceso controlado (datos de prueba ficticios en el laboratorio académico).

## 5. Organización lógica propuesta (AD)

### Sitios de Active Directory (4)

| Sitio AD | Sucursal | Subred |
|----------|----------|--------|
| `SC-Central` | Santa Cruz Central (matriz) | `192.168.10.0/24` |
| `SC-Norte` | Santa Cruz Norte | `192.168.20.0/24` |
| `SC-Este` | Santa Cruz Este | `192.168.30.0/24` |
| `SC-Sur` | Cota Brus Sur | `192.168.40.0/24` |

### Unidades Organizativas (4, una por sucursal)

| UO | Sucursal | Grupos (3 por UO) |
|----|----------|-------------------|
| `UO_SC_Central` | Central | G_Central_Usuarios, G_Central_Supervisores, G_Central_Impresion |
| `UO_SC_Norte` | Norte | G_Norte_Usuarios, G_Norte_Supervisores, G_Norte_Impresion |
| `UO_SC_Este` | Este | G_Este_Usuarios, G_Este_Supervisores, G_Este_Impresion |
| `UO_SC_Sur` | Sur | G_Sur_Usuarios, G_Sur_Supervisores, G_Sur_Impresion |

Cada grupo con **5 usuarios mínimo**.  
Total: 4 UO × 3 grupos × 5 usuarios = **60 usuarios** (supera el mínimo de 45).

## 6. Objetivos del proyecto (para el informe)

- Diseñar una arquitectura de red empresarial distribuida en 4 sucursales para Laboratorio Mabe.
- Implementar en VirtualBox los servicios exigidos sobre Windows Server 2025 Standard.
- Administrar usuarios, grupos y recursos mediante Active Directory, Sites y GPO.
- Incorporar seguridad, virtualización y continuidad operativa con responsabilidad social.
- Documentar y defender técnicamente la solución.

## 7. Alcance

**Incluye:** 2 servidores Windows Server 2025, 4 estaciones cliente (1 por sucursal), dominio `mabe.tso1` con 4 Sites, servicios de la consigna, RRAS inter-VLAN, seguridad, Hyper-V, backup, informe y presentación.

**No incluye:** integración real con equipos de laboratorio (LIS), historia clínica electrónica en producción, certificado público real, ni exposición de servicios a Internet.
