# Resumen simple: Implementación de 4 sucursales — Laboratorio Mabe

## Idea en una frase

Laboratorio Mabe tiene 4 sucursales. Cada una en su propia subred. El servidor DC central tiene una "pierna" (NIC) en cada subred y hace de router. El servidor APP central queda en la red principal y las sucursales lo alcanzan vía el router.

---

## Topología visual

```
         [intnet-mabe-norte]  192.168.20.0/24
                 │
         [intnet-mabe-este]   192.168.30.0/24
                 │
    ┌────────────┴────────────┐
    │  SRV-DC01 (4 NICs)       │
    │  AD + DNS + DHCP + RRAS  │
    │  IP .10 en cada subred   │
    │  (router inter-VLAN)     │
    └────────────┬────────────┘
                 │
         [intnet-mabe-sur]    192.168.40.0/24
                 │
         [intnet-mabe-central] 192.168.10.0/24
                 │
    ┌────────────┴────────────┐
    │  SRV-APP01 (1 NIC)       │
    │  IIS + Archivos + Print  │
    │  + Correo + RDP          │
    │  IP: 192.168.10.20       │
    └─────────────────────────┘
```

Cada sucursal tiene su propia red interna en VirtualBox y su propia VM cliente.

---

## Subredes

| Sucursal | Subred | Red VirtualBox | IP del DC |
|----------|--------|----------------|-----------|
| Central (matriz) | 192.168.10.0/24 | intnet-mabe-central | .10.10 |
| Norte | 192.168.20.0/24 | intnet-mabe-norte | .20.10 |
| Este | 192.168.30.0/24 | intnet-mabe-este | .30.10 |
| Sur | 192.168.40.0/24 | intnet-mabe-sur | .40.10 |

---

## DHCP (4 scopes)

Cada sucursal tiene su propio scope. El DC entrega IPs en las 4 subredes porque tiene una NIC en cada una.

| Scope | Rango | Exclusión | Gateway | DNS |
|-------|-------|-----------|---------|-----|
| Central | .10.100 a .10.200 | .10.1 a .10.50 | .10.10 | .10.10 |
| Norte | .20.100 a .20.200 | .20.1 a .20.50 | .20.10 | .20.10 |
| Este | .30.100 to .30.200 | .30.1 to .30.50 | .30.10 | .30.10 |
| Sur | .40.100 to .40.200 | .40.1 to .40.50 | .40.10 | .40.10 |

---

## Routing (cómo las sucursales llegan a APP01)

1. Cliente en Norte quiere abrir `http://srv-app01.mabe.tso1`
2. DNS resuelve a `192.168.10.20` (una sola IP, limpia)
3. Cliente ve que la IP está en otra subred, manda al gateway `192.168.20.10` (DC)
4. El DC recibe, enruta hacia su NIC central y entrega a APP01
5. APP01 responde al cliente vía el DC
6. El cliente recibe la página

**El rol que hace esto posible:** RRAS (LAN routing) en SRV-DC01.

---

## Active Directory Sites

4 sitios en AD Sites and Services, uno por sucursal, con sus 4 subredes asociadas. Sirve para:
- Organizar los equipos por ubicación
- Enlazar GPO por sitio (más realista)
- Argumento de defensa: diseño empresarial multi-sitio

---

## Unidades Organizativas (AD)

4 UO, una por sucursal. Cada una con 3 grupos y 5+ usuarios por grupo.

| UO | Grupos |
|----|--------|
| UO_SC_Central | G_Central_Usuarios, G_Central_Supervisores, G_Central_Impresion |
| UO_SC_Norte | G_Norte_Usuarios, G_Norte_Supervisores, G_Norte_Impresion |
| UO_SC_Este | G_Este_Usuarios, G_Este_Supervisores, G_Este_Impresion |
| UO_SC_Sur | G_Sur_Usuarios, G_Sur_Supervisores, G_Sur_Impresion |

Total: 4 UO, 12 grupos, 60 usuarios.

---

## Clientes (1 por sucursal)

| VM | Red interna | IP (DHCP) |
|----|-------------|-----------|
| PC-REC01 | intnet-mabe-central | 192.168.10.x |
| PC-NORTE01 | intnet-mabe-norte | 192.168.20.x |
| PC-ESTE01 | intnet-mabe-este | 192.168.30.x |
| PC-SUR01 | intnet-mabe-sur | 192.168.40.x |

Para demostrar una sucursal: encender DC + APP01 + esa VM cliente.

---

## Orden de implementación (resumen)

1. Crear 4 redes internas en VirtualBox
2. Agregar 4 NICs al DC (uno por red)
3. Configurar 4 IPs estáticas en el DC
4. Instalar AD + DNS + DHCP (4 scopes)
5. Habilitar RRAS LAN routing en el DC
6. Configurar AD Sites + Subnets
7. Correr scripts OU/grupos/usuarios
8. Configurar APP01 (1 NIC, gateway = DC central)
9. Crear/Clonar 4 VMs cliente
10. Unir cada cliente a su red y al dominio
11. Probar DHCP + login + web + archivos desde cada sucursal

---

## RAM estimada

| VM | RAM |
|----|-----|
| SRV-DC01 (4 NICs) | 4-6 GB |
| SRV-APP01 | 4 GB |
| 1 cliente activo a la vez | 2-4 GB |
| **Total en ejecución** | **10-14 GB** |

---

## Por qué este enfoque

- Cumple el enunciado (2 servidores)
- No recarga la laptop (no hay 4 DCs reales)
- Las sucursales acceden a APP01 (RRAS routing)
- Demuestra AD Sites, multi-NIC y enrutamiento inter-VLAN
- Argumento sólido para la defensa
