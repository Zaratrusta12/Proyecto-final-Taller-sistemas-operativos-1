# Revisión topología draw.io — Laboratorio Mabe

**Fecha revisión:** 2026-07-27  
**Estado:** Aprobada con ajustes menores

## Lo que está bien

- Título y contexto Laboratorio Mabe
- Switch central con los 3 equipos
- Hostnames e IPs correctos: DC01 `.10`, APP01 `.20`
- Servicios bien repartidos (AD/DNS/DHCP vs IIS/correo/archivos/impresión)
- Red interna `intnet-mabe` documentada
- PC-REC01 como estación de trabajo
- Impresoras (3) alineado al requisito 1 por UO

## Ajustes obligatorios

| #   | Ahora                                             | Debe quedar                             | Por qué                                     |
| --- | ------------------------------------------------- | --------------------------------------- | ------------------------------------------- |
| 1   | Revisar texto del dominio en el recuadro amarillo | Exactamente **`mabe.tso1`** (con punto) | Formato del enunciado: `NombreEmpresa.tso1` |

En el informe y al promover el DC, escribir siempre: `mabe.tso1`

## Ajustes recomendados (informe más sólido)

1. Agregar bajo PC-REC01: `DHCP 192.168.10.100-200`
2. En el switch o pie: `LAN 192.168.10.0/24` + `Exclusión .1-.50`
3. Opcional en DC01: etiqueta **GPO (15)**
4. Opcional: **RDP** en ambos servers
5. Opcional fase final: caja **Hyper-V** (VM anidada) en APP01 o DC01
6. Exportar PNG alta resolución a:
   `01_Diseno/topologia/topologia_mabe.png`

## Veredicto

**Sirve para el proyecto.** Corrijan el dominio si el punto no se ve claro, sumen la nota de DHCP/exclusión cuando puedan, y guarden el `.drawio` + PNG en la carpeta de topología.
