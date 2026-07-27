# ACTIVIDAD VII - PROYECTO SOCIOFORMATIVO INTEGRADOR
**Asignatura:** Taller de Sistemas Operativos I  
**Institución:** Universidad Privada Domingo Savio (UPDS)  
**Docente:** Ing. Alex Escobar  

---

## 1. DATOS GENERALES

* **ASIGNATURA:** Taller de Sistemas Operativos I
* **CARRERAS:** Ingeniería en Sistemas
* **SEMESTRE:** 3er Semestre

---

## 2. OBJETIVOS DE APRENDIZAJE

Al terminar esta actividad, el estudiante habrá desarrollado las siguientes capacidades:

* **Diseñar** una arquitectura de red empresarial que integre servicios de infraestructura TI utilizando **Windows Server 2022**.
* **Implementar y configurar** los servicios de red esenciales (**DHCP, DNS, WEB, CORREO, ACCESO REMOTO**) en un entorno virtualizado que simule un escenario empresarial real.
* **Administrar** los recursos de la red mediante la implementación de **Active Directory** y la formulación de **políticas de grupo (GPO)**.
* **Incorporar** políticas de seguridad, sistemas de virtualización y planes de contingencia, actuando con ética y responsabilidad social.
* **Documentar y defender** técnicamente el proyecto, demostrando dominio de los conceptos y habilidades adquiridas.

### Ejes de Transversalización y ODS
* **Ejes de transversalización de la asignatura:**
  * *"Tecnologías Emergentes y Adaptabilidad Digital"*
  * *"Investigación y Pensamiento Crítico"*
* **Objetivos de Desarrollo Sostenible (ODS):**
  * Particularmente el ODS de *"Industria, Innovación e Infraestructura"*.

---

## 3. CONTEXTUALIZACIÓN

En **Santa Cruz**, múltiples empresas de servicios sufren constantes interrupciones en sus plataformas digitales debido a configuraciones deficientes en sus infraestructuras locales. Esta situación genera:
* Pérdidas económicas recurrentes.
* Vulnerabilidades críticas de seguridad.
* Lentitud operativa por la falta de un control centralizado de usuarios.

Por lo tanto, se requiere desplegar servidores corporativos robustos y seguros bajo estándares actuales que automaticen los servicios de red, mitiguen riesgos cibernéticos y garanticen la continuidad del negocio.

El presente **proyecto socioformativo integrador** responde directamente a esta problemática, desafiando a los estudiantes a diseñar, implementar y documentar una infraestructura de red completa basada en **Windows Server 2022**, aplicando los conocimientos y habilidades desarrollados a lo largo de la asignatura.

---

## 4. CONSIGNA

Cada grupo, de forma colaborativa, deberá cumplir con las siguientes etapas:

### 4.1. Selección y aprobación de la empresa
1. Cada grupo deberá seleccionar una empresa real o simulada (PyME, institución educativa, organización sin fines de lucro, etc.) con sede en **Santa Cruz de la Sierra** o el entorno regional, a la cual se le aplicará el proyecto.
2. El docente aprobará o sugerirá ajustes a la empresa seleccionada, garantizando que cumpla con los criterios de la asignatura y sea un escenario viable para el proyecto.

### 4.2. Diseño de la arquitectura de red
1. Diseñar la arquitectura de red de la empresa, incluyendo:
   * **Topología de red:** Diagrama elaborado en *Cisco Packet Tracer*, *Lucidchart* o herramienta similar.
   * **Asignación de direccionamiento IP.**
   * **Descripción detallada** de los servicios que se implementarán.

### 4.3. Implementación en entorno virtualizado
1. En **VirtualBox**, implementar la infraestructura diseñada, la cual deberá incluir:
   * **Windows Server 2022 Standard (Experiencia de Escritorio):** Como controlador de dominio y servidor de servicios.
   * **Active Directory Domain Services (AD DS):** Para la gestión centralizada de usuarios, equipos y políticas.
   * **Servidor DHCP:** Para la asignación automática de direcciones IP.
   * **Servidor DNS:** Para la resolución de nombres interna y externa.
   * **Servidor Web (IIS):** Para alojar un sitio web corporativo (puede ser una página simple).
   * **Servidor de Correo:** Servidor SMTP/POP3 (ej. *hMailServer*) o integración con servicios externos.
   * **Servidor de Archivos:** Para el almacenamiento y compartición de documentos.
   * **Servidor de Impresión:** Para la gestión centralizada de impresoras.
   * **Acceso Remoto:** Configuración de Escritorio Remoto (RDP) para administración remota.

### 4.4. Seguridad y virtualización
1. **Implementar políticas de seguridad:**
   * Políticas de contraseñas y bloqueo de cuentas.
   * Políticas de Grupo (**GPO**) para restringir el acceso y configurar estaciones de trabajo.
   * Configuración del **Firewall de Windows** para proteger los servicios.
2. **Implementar un sistema de virtualización:**
   * Instalar y configurar **Hyper-V** para crear al menos una máquina virtual adicional dentro del servidor (ej. un servidor de aplicaciones o base de datos).
3. **Diseñar un plan de contingencia:**
   * Configurar copias de seguridad (**Windows Server Backup**).
   * Definir un procedimiento estructurado de recuperación ante fallos.

### 4.5. Documentación del proyecto
1. Elaborar un informe técnico completo que contenga:
   * **Portada:** Con datos académicos y personales.
   * **Introducción:** Contexto, objetivos y alcance.
   * **Descripción de la empresa** y sus necesidades de TI.
   * **Diseño de la arquitectura de red:** Diagramas y justificación técnica.
   * **Paso a paso** de la instalación y configuración de cada servicio (con capturas de pantalla).
   * **Configuración** de seguridad, virtualización y plan de contingencia.
   * **Pruebas de funcionamiento:** Evidencias de que los servicios operan correctamente.
   * **Conclusiones y recomendaciones.**
   * **Bibliografía:** Exclusivamente fuentes confiables.
   * **Anexos:** (Opcional).
2. **Extensión:** El documento deberá tener una extensión mínima de **25 páginas** (sin contar portada, índices, bibliografía ni anexos).

### 4.6. Resumen técnico de la infraestructura

#### SERVER 1
* **Active Directory:** Dominio en formato `NombreEmpresa.tso1`
* **Servidor DNS**
* **Servidor DHCP:** Debe incluir por lo menos **1 rango de IPs de exclusión**.
* **Unidades Organizativas (UO):** Mínimo **3 UOs**.
* **Grupos:**
  * Por lo menos **3 grupos por UO**.
  * Por lo menos **5 usuarios por grupo**.
* **GPOs (Políticas de Grupo):** Mínimo **15 GPOs**.

#### SERVER 2
* **Servidor de Impresión:** Mínimo **1 impresora compartida por UO**.
* **Servidor de Sitios Web (IIS):** Un sitio web empresarial compuesto por **5 páginas básicas**.
* **Servidor de Archivos y Almacenamiento:**
  * Con distintos tipos de permisos de acceso para usuarios.
  * Asignación de diferentes **Cuotas de Disco** por grupo.

#### ESTACIÓN DE TRABAJO
* Máquina cliente para realizar la verificación y validación del correcto funcionamiento de todos los servicios.

### 4.7. Presentación y defensa
1. **Presentación:** Elaborar un archivo de presentación (*PowerPoint*, *Canva* o *Google Slides*) con un máximo de **15 diapositivas** y un límite estricto de **7 palabras por diapositiva** (se deben utilizar únicamente imágenes y palabras clave).
2. **Demostración en vivo:** Realizar una demostración práctica del funcionamiento de la infraestructura implementada, evidenciando el correcto despliegue de los servicios y configuraciones.
3. **Defensa:** El docente designará individualmente qué integrantes realizarán la presentación y quiénes defenderán el proyecto respondiendo preguntas técnicas sobre el diseño, implementación y decisiones tomadas.

---

## 5. FORMATO DE ENTREGA Y REQUISITOS

| Requisito | Descripción |
| :--- | :--- |
| **Informe técnico** | Documento en formato **PDF**, estructurado según la *Guía de Redacción de la UPDS* y bajo normas **APA 7**. Extensión mínima de **25 páginas**. |
| **Demostración** | Duración máxima de **10 minutos**, donde se evidencie el funcionamiento operativo de la infraestructura implementada. |
| **Presentación** | Archivo de presentación (PPT, PDF o enlace a Canva/Google Slides) con un máximo de **15 diapositivas** y **7 palabras por diapositiva**. |
| **Entrega en Plataforma** | Comprimir todos los entregables (informe PDF + presentación) en un archivo `.RAR` con la nomenclatura: `[Grupo # - Nombre de la Empresa].RAR`. Subir de forma individual en la sección "Entregable Final" dentro del plazo establecido. |
| **Entrega física** | El docente podrá solicitar una copia impresa del informe técnico. |
| **Fecha de entrega** | **31 de julio de 2026** (o según ajuste del calendario académico). |

---

## 6. CRITERIOS DE EVALUACIÓN

* **Criterio de Verificación 4:** *"Implementa sistemas de seguridad en entornos Windows y sistemas de virtualización en base a la ética y responsabilidad social"*.
* **Puntaje:** Tiene un valor asignado de **20 puntos** sobre la nota final de la asignatura.

---

## 7. NOTA IMPORTANTE

Esta actividad integra la totalidad de los conocimientos y habilidades desarrollados durante la asignatura. La presentación y defensa del proyecto es de carácter **estrictamente obligatorio** para la aprobación de la materia. La no entrega o entrega incompleta derivará en la pérdida del **20%** correspondiente a la nota final.
