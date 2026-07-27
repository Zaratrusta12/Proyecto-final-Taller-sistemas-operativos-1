# Ficha de la empresa — Laboratorio Mabe

## 1. Datos generales

| Campo | Detalle |
|-------|---------|
| Nombre | Laboratorio Mabe |
| Rubro | Análisis clínicos y diagnóstico de laboratorio |
| Ubicación | Santa Cruz de la Sierra, Bolivia |
| Tipo | PyME de servicios de salud |
| Tamaño simulado | Aprox. 35 colaboradores |
| Áreas principales | Recepción, Laboratorio (analistas), Administración, Sistemas |

## 2. Descripción

Laboratorio Mabe es un laboratorio de análisis clínicos que atiende pacientes particulares y convenios con seguros y clínicas de la ciudad. Su operación diaria depende de la recepción de muestras, el procesamiento en área técnica, la emisión de resultados y la gestión administrativa (facturación, compras y recursos humanos).

En el escenario del proyecto, la organización opera con equipos en grupo de trabajo, direcciones IP asignadas de forma manual, carpetas compartidas sin control centralizado y sin políticas de seguridad homogéneas. Esa situación genera interrupciones, riesgo de pérdida de información y dificultad para auditar accesos a datos sensibles.

## 3. Problemática de TI (alineada al enunciado)

En Santa Cruz, empresas de servicios como Laboratorio Mabe sufren interrupciones en sus plataformas digitales por configuraciones deficientes en la infraestructura local. En este caso se identifican:

- Pérdidas de tiempo operativo por fallas de red y cuentas locales dispersas.
- Vulnerabilidades de seguridad al no existir control centralizado de usuarios ni políticas de contraseñas.
- Lentitud y desorden al compartir archivos clínicos y administrativos sin permisos por área.
- Ausencia de un plan formal de respaldo y recuperación ante fallos.
- Falta de servicios internos básicos: DNS/DHCP corporativo, web institucional, impresión centralizada y correo interno.

## 4. Necesidades de TI del proyecto

1. **Identidad centralizada** con Active Directory (`mabe.tso1`).
2. **Red automática** con DHCP (y rango de exclusión para servidores).
3. **Resolución de nombres** con DNS interno.
4. **Sitio web corporativo** (IIS) con información institucional.
5. **Servidor de archivos** con permisos por área y cuotas de disco.
6. **Impresión centralizada** (al menos una impresora por unidad organizativa).
7. **Correo interno** para coordinación entre áreas.
8. **Acceso remoto** (RDP) restringido a administración.
9. **Políticas de grupo (GPO)** para estandarizar y asegurar estaciones.
10. **Virtualización (Hyper-V)**, **firewall**, **backup** y plan de contingencia.
11. **Enfoque ético:** protección de datos de pacientes con cuentas nominativas, menor privilegio y evidencias de acceso controlado (datos de prueba ficticios en el laboratorio académico).

## 5. Organización lógica propuesta (AD)

| Unidad organizativa | Función en el lab | Ejemplos de puestos |
|---------------------|-------------------|---------------------|
| UO_Recepcion | Admisión de pacientes y muestras | Recepcionista, caja, call center |
| UO_Laboratorio | Análisis y validación técnica | Bioquímico, tecnólogo, jefe de lab |
| UO_Administracion | Gestión interna | Contabilidad, RRHH, gerencia |

## 6. Objetivos del proyecto (para el informe)

- Diseñar una arquitectura de red empresarial adecuada a Laboratorio Mabe.
- Implementar en VirtualBox los servicios exigidos sobre Windows Server 2025 Standard.
- Administrar usuarios, grupos y recursos mediante Active Directory y GPO.
- Incorporar seguridad, virtualización y continuidad operativa con responsabilidad social.
- Documentar y defender técnicamente la solución.

## 7. Alcance

**Incluye:** 2 servidores Windows Server 2025, 1 estación cliente, dominio `mabe.tso1`, servicios de la consignas, seguridad, Hyper-V, backup, informe y presentación.

**No incluye:** integración real con equipos de laboratorio (LIS), historia clínica electrónica en producción, certificado público real, ni exposición de servicios a Internet.
