# Análisis: Acceso de sucursales a SRV-APP01

**Modo:** plan (análisis, sin implementación).  
**Pregunta:** ¿Cómo hacer que SRV-APP01 sea alcanzable desde las 4 sucursales?  
Opciones evaluadas: (A) 4 NICs en APP01, (B) routing desde las subredes hacia la central.

---

## Contexto actual del diseño

- 4 redes internas en VirtualBox (una por sucursal)
- SRV-DC01 con 4 NICs (una por subred), IPs `.10` en cada una
- SRV-APP01 con 1 NIC en la red central (`192.168.10.20`)
- Clientes en cada sucursal con gateway = IP del DC en su subred

**Problema a resolver:** un cliente en Sucursal Norte (`192.168.20.x`) no puede llegar a APP01 (`192.168.10.20`) porque no hay routing entre redes internas.

---

## Opción A — Dar 4 NICs a APP01 (multi-homed)

### Concepto
APP01 con un adaptador en cada red interna, igual que el DC. IPs:
- Central: `192.168.10.20`
- Norte: `192.168.20.20`
- Este: `192.168.30.20`
- Sur: `192.168.40.20`

### Por qué parece tentador
Sin router, sin relay, APP01 reach L2 directo en cada subred.

### Por qué NO es buena idea (problemas reales de multi-homing en Windows Server)

1. **DNS registra múltiples A records.** APP01 publica 4 IPs en DNS. Un cliente en Norte hace `nslookup srv-app01.mabe.tso1` y recibe las 4 IPs. Windows intenta la primera (que puede ser la central `.10.20`), no llega (no hay routing), espera timeout, prueba la siguiente, y recién llega a la `.20.20`. Esto genera **demoras de 15-30 segundos** cada vez que un cliente accede a web/archivos/correo. En la defensa, luciría lento y dando tumbos.

2. **Un solo default gateway.** Windows solo soporta un default gateway real. Con 4 NICs y gateways configurados, la tabla de rutas se vuelve impredecible y tráfico puede salir por la interfaz equivocada.

3. **Registro DNS duplicado / entrada en zona inversa.** Limpieza de DNS requiere desactivar registro en las NICs "secundarias" o configurar manualmente registros A por sitio. Mucho trabajo manual frágil.

4. **Firewall de Windows.** con 4 perfiles de red el firewall puede bloquear tráfico en una NIC y permitírselo en otra. Difícil de auditar.

5. **Es un antipatrón en producción.** En la vida real nadie pone un servidor de aplicaciones con 4 tarjetas en 4 VLANs; se enruta. Un docente que conozca redes podría preguntar por qué multi-homing y la respuesta "porque no supe enrutar" no defiende bien.

### Veredicto Opción A
**No recomendada.** Aparentemente simple pero genera problemas de DNS, timeouts en el demo y se ve poco profesional en la defensa.

---

## Opción B — Habilitar routing en SRV-DC01 (RRAS LAN routing) — RECOMENDADA

### Concepto
El DC ya tiene 4 NICs (una por subred). Es el punto natural para hacer de **router** entre las 4 subredes. Se habilita **LAN routing** con RRAS (Remote Access role, solo la parte de routing, sin VPN ni NAT). No es una VM nueva: es un rol más en el DC.

### Cómo funciona el tráfico

Cliente en Sucursal Norte (`192.168.20.105`, gateway `192.168.20.10` = DC) quiere acceder a `http://srv-app01.mabe.tso1`:

1. DNS resuelve `srv-app01` → `192.168.10.20` (una sola IP limpia en DNS)
2. Cliente ve que `.10.20` está en otra subred → manda al gateway `192.168.20.10` (DC)
3. DC recibe, ve que `.10.20` está en su NIC central → reenvía por esa interfaz
4. APP01 recibe, responde a `.20.105` → manda a su gateway `192.168.10.10` (DC)
5. DC enruta la respuesta de vuelta a la NIC Norte
6. Cliente recibe la página web

**Sin timeouts, sin DNS múltiple, sin NICs extra en APP01.**

### Configuración necesaria (cuando implementemos)

1. En SRV-DC01, instalar rol **Remote Access** (solo RRAS, LAN routing):
   ```powershell
   Install-WindowsFeature Routing -IncludeManagementTools
   Install-RemoteAccess -VpnType None
   # luego habilitar IPv4 LAN routing en la consola RRAS (rrasmgmt.msc)
   ```
   O con GUI: Server Manager → Add roles → Remote Access → Routing → Enable LAN routing.

2. En RRAS console: IPv4 → General → habilitar "LAN routing" en cada interfaz.

3. APP01: gateway = `192.168.10.10` (DC central), DNS = `192.168.10.10`. Una sola NIC, una sola IP, un solo registro A en DNS.

4. Firewall del DC: permitir tráfico en tránsito (RRAS suele abrir lo necesario, pero conviene verificar reglas para puertos 80, 443, 445, 25, 110, 143, 3389).

5. DHCP: ya configurado con gateway = IP del DC en cada subred. No hay que tocar nada nuevo.

### Ventajas

- **APP01 queda single-homed:** DNS limpio, una sola IP, sin timeouts, sin problemas de firewall multi-NIC.
- **Acceso total:** cualquier cliente de cualquier sucursal llega a APP01 (web, archivos, impresión, correo, RDP).
- **Realista:** así funcionan las empresas reales, router central enruta entre VLANs/subredes.
- **Argumento de defensa sólido:** demuestra conocimiento de RRAS y enrutamiento inter-VLAN, alineado al criterio "Acceso Remoto" del enunciado.
- **Sin VM extra:** no consume RAM adicional, el DC asume el rol de router.
- **Sin cambios en DHCP:** los scopes ya tienen el gateway correcto (la IP del DC en cada subred).

### Desventajas

- El DC acumula roles (AD + DNS + DHCP + Router). En un laboratorio académico es aceptable; en producción se separa, pero el enunciado pide 2 servidores y el DC es el único con 4 NICs.
- RRAS adds un paso de configuración extra (~15 min).
- Si el DC se cae, todo cae (pero ya es el DC central, así que es el punto único de falla de toda forma).

### Veredicto Opción B
**Recomendada.** Es la forma correcta, realista y limpia. Demuestra dominio de routing y mantiene APP01 simple. Fuerte para la defensa.

---

## Comparación

| Criterio | Opción A (4 NICs APP01) | Opción B (RRAS en DC) |
|----------|--------------------------|------------------------|
| Complejidad config | Aparenta simple | Media (RRAS) |
| DNS limpio | No (4 A records, timeouts) | Sí (1 A record) |
| Acceso total sucursales → APP01 | Sí pero lento | Sí, rápido |
| RAM extra | No | No |
| Default gateway único | Problemático | Limpio |
| Realismo productivo | Bajo (antipatrón) | Alto |
| Argumento defensa | Débil | Fuerte (RRAS/routing) |
| Riesgo en demo | Medio (timeouts) | Bajo |

---

## Recomendación final

**Opción B: habilitar LAN routing en SRV-DC01 con RRAS.**

- APP01 con 1 NIC en la central (limpio)
- DC hace de router entre las 4 subredes
- Todas las sucursales acceden a todos los servicios de APP01
- Sin timeouts de DNS multi-homed
- Cumple y refuerza el criterio de verificación de "Acceso Remoto" (10363)

### Bonus para el informe y la defensa

- Sección "Enrutamiento inter-VLAN con RRAS" como argumento técnico
- Tabla de rutas del DC (`route print`)
- Captura del RRAS Manager mostrando LAN routing habilitado
- Pruebas de acceso web desde cada sucursal (4 capturas que demuestran routing funcional)

### Impacto en lo ya hecho

| Documento | Cambio |
|-----------|--------|
| `servicios.md` | Agregar rol RRAS (LAN routing) al DC |
| `direccionamiento_ip.md` | Gateway de APP01 = `.10.10` (DC central) |
| Topología draw.io | Mostrar DC como router entre sucursales |
| Informe | Sección nueva de routing inter-VLAN |
| Checklist implementación | Agregar pasos de RRAS |

---

## Pregunta para confirmar

¿Confirmamos **Opción B (RRAS LAN routing en el DC)**?

Si sí, actualizo los documentos de diseño y agrego los pasos de RRAS al checklist del Día 2 o 3. Nada se implementa hasta que digas **dale**.
