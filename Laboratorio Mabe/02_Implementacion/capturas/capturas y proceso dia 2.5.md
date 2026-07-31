desde el punto 8. del checklist 2,

# 8.

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_13_03_20.png)

Utilizando los complementos de invitados de virtual box envio una carpeta desde la maquina anfitriona con  los scrips necesarios para la creacion de grupos y usuarios en el dominio mabe.tso1

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_13_06_16.png)

ejecuto un bypass termporal de seguridad y ejecuto los 2 scrips en el servidor



![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_13_09_23.png)

para confirmar que los cambios fueran ejecutas con exito ingreso desde herramientas a usuarios y equipos de active directory

se puede observa un UO por cada sucursal

3 grupos de seguridad por cada UO

y 15 usuarios en cada UO

la contraseña asignada para cada usuario es: User#Lab

# 9.

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_13_14_54.png)

desde el srv-app01 verifico la conexion con la IP otorgada por el DHCP



![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_13_17_04.png)

ingreso desde configuracion de windows para asignar el dominio mabe.tso1 dentro del srv-app01

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_13_49_57.png)

tambien ingreso la ip del servidor DNS, ya que el servidor app se maneja con IP fija

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_13_51_41.png)

ingreso las credenciales del administrador del controlador de dominio e ingreso al dominio

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_13_51_49.png)

ingreso al dominio exitoso, la maquina procede a reiniciarse

# 10.

El sigueinte paso seria ingresar todas las maquinas clientes al mismo dominio

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_14_09_19.png)

dentro de la maquina de la sucursal norte ingreso el dominio y las credenciales

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_14_18_14.png)

ingresamos con un usuario que pertenezca a la unidad organizativa segun la sucursal de la maquina cliente

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_14_28_55.png)

una vez realizado ya tendremos cada maquina cliente conectada al dominio y asignada con un usuario de su unidad organizativa

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_14_28_36.png)

incluso podremos observar desde el administrador de DHCP la IP exacta concedida a las maquinas clientes validando las conexiones

# 11.

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_14_36_53.png)

desde configuracion habilito el escritorio remoto en el srv-dc01

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-REC01\VirtualBox_PC-REC01_30_07_2026_14_38_16.png)

desde la maquina cliente ingreso a conexion a escritorio remoto y conecto al equipo 192.168.10.10

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-REC01\VirtualBox_PC-REC01_30_07_2026_14_40_19.png)

ingreso las credenciales de administrador en el servidor dc01

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-REC01\VirtualBox_PC-REC01_30_07_2026_14_42_26.png)se observa como es posible el acceso a escritorio remoto desde una maquina cliente


