# Plan de direccionamiento IP — Laboratorio Mabe (4 sucursales)

## Parámetros de red

| Parámetro | Valor |
|-----------|--------|
| Dominio DNS | `mabe.tso1` |
| Red VirtualBox Central | Internal Network: `intnet-mabe-central` |
| Red VirtualBox Norte | Internal Network: `intnet-mabe-norte` |
| Red VirtualBox Este | Internal Network: `intnet-mabe-este` |
| Red VirtualBox Sur | Internal Network: `intnet-mabe-sur` |
| Router inter-VLAN | SRV-DC01 (rol RRAS LAN routing) |

> SRV-DC01 tiene 4 NICs, una por sucursal. Hace de router entre las 4 subredes con RRAS.
> SRV-APP01 tiene 1 NIC en la central. Las sucursales acceden a APP01 vía routing del DC.

## Subredes por sucursal

| Sucursal | Sitio AD | Subred | Red VirtualBox |
|----------|----------|--------|----------------|
| Santa Cruz Central (matriz) | `SC-Central` | `192.168.10.0/24` | `intnet-mabe-central` |
| Santa Cruz Norte | `SC-Norte` | `192.168.20.0/24` | `intnet-mabe-norte` |
| Santa Cruz Este | `SC-Este` | `192.168.30.0/24` | `intnet-mabe-este` |
| Cota Brus Sur | `SC-Sur` | `192.168.40.0/24` | `intnet-mabe-sur` |

## Asignación estática

### SRV-DC01 (4 NICs)

| NIC | Red interna | IP | Máscara | No usa gateway (es el gateway) |
|-----|-------------|----|---------|---------------------------------|
| Adapter 1 (Central) | intnet-mabe-central | `192.168.10.10` | `255.255.255.0` | — |
| Adapter 2 (Norte) | intnet-mabe-norte | `192.168.20.10` | `255.255.255.0` | — |
| Adapter 3 (Este) | intnet-mabe-este | `192.168.30.10` | `255.255.255.0` | — |
| Adapter 4 (Sur) | intnet-mabe-sur | `192.168.40.10` | `255.255.255.0` | — |

> El DC es el gateway de cada subred. No necesita default gateway configurado (salvo si quieren salir a Internet por NAT en un 5to adaptador, opcional).

### SRV-APP01 (1 NIC)

| NIC | Red interna | IP | Máscara | Gateway | DNS |
|-----|-------------|----|---------|---------|-----|
| Adapter 1 | intnet-mabe-central | `192.168.10.20` | `255.255.255.0` | `192.168.10.10` | `192.168.10.10` |

### Clientes (DHCP, 1 por sucursal)

| VM | Hostname | Red interna | IP esperada | Gateway | DNS |
|----|----------|-------------|-------------|---------|-----|
| PC-REC01 | Central | intnet-mabe-central | `192.168.10.100-200` | `192.168.10.10` | `192.168.10.10` |
| PC-NORTE01 | Norte | intnet-mabe-norte | `192.168.20.100-200` | `192.168.20.10` | `192.168.20.10` |
| PC-ESTE01 | Este | intnet-mabe-este | `192.168.30.100-200` | `192.168.30.10` | `192.168.30.10` |
| PC-SUR01 | Sur | intnet-mabe-sur | `192.168.40.100-200` | `192.168.40.10` | `192.168.40.10` |

## Scopes DHCP (4 total, con exclusión cada uno)

| Scope | Subred | Rango | Exclusión | Gateway | DNS | Domain |
|-------|--------|-------|-----------|---------|-----|--------|
| LAN-Central | `192.168.10.0` | `.100-.200` | `.1-.50` | `192.168.10.10` | `192.168.10.10` | `mabe.tso1` |
| LAN-Norte | `192.168.20.0` | `.100-.200` | `.1-.50` | `192.168.20.10` | `192.168.20.10` | `mabe.tso1` |
| LAN-Este | `192.168.30.0` | `.100-.200` | `.1-.50` | `192.168.30.10` | `192.168.30.10` | `mabe.tso1` |
| LAN-Sur | `192.168.40.0` | `.100-.200` | `.1-.50` | `192.168.40.10` | `192.168.40.10` | `mabe.tso1` |

> Cada scope entrega como gateway y DNS la IP del DC en esa subred.

## Impresoras lógicas (documentadas)

| Nombre | IP referencial | UO |
|--------|----------------|-----|
| IMP-Recepcion-Central | `192.168.10.30` | UO_SC_Central |
| IMP-Laboratorio-Central | `192.168.10.31` | UO_SC_Central |
| IMP-Norte | `192.168.20.30` | UO_SC_Norte |
| IMP-Este | `192.168.30.30` | UO_SC_Este |
| IMP-Sur | `192.168.40.30` | UO_SC_Sur |

## Reglas rápidas

1. Servidores: IP estática fuera del pool (dentro de la exclusión `.1-.50`).
2. Clientes: DHCP.
3. DNS de miembros del dominio: siempre la IP del DC en su subred (Norte usa `.20.10`, Este `.30.10`, etc.).
4. APP01: gateway `192.168.10.10` (DC central) para que el DC enrute respuestas hacia las sucursales.
5. Antes de unir al dominio: verificar `ping <IP del DC en la subred>` y `nslookup mabe.tso1`.
6. RRAS en el DC enruta entre las 4 subredes. No hay router VM separado.
