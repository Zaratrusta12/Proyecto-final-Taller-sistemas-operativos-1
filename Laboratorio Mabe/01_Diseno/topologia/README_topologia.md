# Topología de red — draw.io

## Archivo a crear

- Trabajar en: [https://app.diagrams.net](https://app.diagrams.net) (draw.io)
- Guardar como: `topologia_mabe.drawio` en esta carpeta
- Exportar PNG/PDF: `topologia_mabe.png` para el informe

## Elementos mínimos del diagrama

1. Título: **Laboratorio Mabe — Topología lógica `mabe.tso1`**
2. Caja o cloud opcional: "Red externa / NAT (solo host)" si usan segundo adaptador
3. Switch lógico (o LAN `192.168.10.0/24`)
4. Tres equipos conectados al switch:
   - **SRV-DC01** `192.168.10.10` — AD DS, DNS, DHCP, GPO
   - **SRV-APP01** `192.168.10.20` — IIS, File, Print, Mail
   - **PC-REC01** DHCP — Estación de trabajo
5. Etiqueta de dominio: `mabe.tso1`
6. Etiqueta VirtualBox: red interna `intnet-mabe`
7. Opcional: iconos de impresoras IMP-REC / IMP-LAB / IMP-ADM
8. Opcional: VM nested Hyper-V dentro de un servidor

## Texto sugerido en el pie del diagrama

Red interna de laboratorio académico. Servidores con IP estática. Clientes por DHCP (exclusión 192.168.10.1-50).

## Checklist visual

- [ ] Se distinguen SERVER1 y SERVER2
- [ ] IPs legibles
- [ ] Servicios etiquetados
- [ ] Cliente presente
- [ ] Exportado en buena resolución para el PDF del informe
