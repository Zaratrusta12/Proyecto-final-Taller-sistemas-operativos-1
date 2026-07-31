# A.

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_05_55.png)

ingreso a la administracion de directivas de grupo para comenzar a asociar GPO

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_11_18.png)

creo GPO_PasswordPolicy y dentro le asigno todas las politicas de contraseña de cuenta

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_12_45.png)

creo un nuevo GPO para el bloqueo de cuentas

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_15_34.png)

le asigno las politicas para bloquear cuenta tras intentos fallidos de contraseña

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_19_45.png)

creo GPO_ScreenLock y le asigno las configuraciones del bloqueo de pantalla

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_20_58.png)

creo GPO_Restrict_USB para politicas de restringir USB

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_22_00.png)

Le asigno la configuracion para evitar escritura en discos extraibles

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_23_33.png)

creo un GPO para habilitar actualizaciones automaticas

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_27_31.png)

aplica las directivas

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-DC01\VirtualBox_SRV-DC01_30_07_2026_16_52_02.png)

(arbol donde se observa todas las GPO vinculadas y configuradas segun su proposito y dominio)

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_17_26_11.png)

CAPTURA DE gpresult /r en maquina NORTE

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-REC01\VirtualBox_PC-REC01_30_07_2026_18_04_05.png)

CAPTURA DE gpresult /r en maquina CENTRAL

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-ESTE01\VirtualBox_PC-ESTE01_30_07_2026_18_10_42.png)

CAPTURA DE gpresult /r en maquina ESTE

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-SUR01\VirtualBox_PC-SUR01_30_07_2026_19_03_35.png)

CAPTURA DE gpresult /r en maquina SUR

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-REC01\VirtualBox_PC-REC01_30_07_2026_19_26_03.png)

VERIFICACION DENTRO DE MAQUINA CLIENTE CENTRAL DE QUE EL ACCESO AL PANEL DE CONTROL ESTA RESTRINGIDO

# B

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_19_45_34.png)

formulario para agregar web habiendo ingresado todas las configuraciones de MabeWeb

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_19_48_17.png)

Navegador con la paginaweb MabeWeb abierta y funcionando correctamente

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_20_04_20.png)

Para comprobarlo en sucursal norte primero elimino el default web para evitar conflictos en el puerto 80 y agrego 2 enlaces en el sitio, 1 sin nombre de host y otro con nombre srv-app01.mabe.tso1

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_20_03_58.png)

Captura de maquina cliente norte con acceso completo mediante routing ~~~~a la pagina del srv-app ubicado en otra subred

# C

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_20_08_26.png)

Captura en explorador de archivos con todas las carpetas a compartir creadas

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_20_16_06.png)

permisos de la carpeta sucursal central

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_20_17_26.png)

permisos carpeta norte

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_20_18_35.png)

Permisos de Este

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_20_19_23.png)

permisos de sur

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_21_11_47.png)

comprobacion de acceso a carpeta compartida desde maquina cliente norte, lectura confirmada

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_21_29_53.png)

como usuario del grupo es posible la creacion o eliminacion de archivos

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_21_39_18.png) 

repaso de la configuracion de seguridad avanzada para cada recurso compartido

se desahiblito la herencia y eliminaron los  Usuarios` (SRV-APP01\Usuarios)

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_21_42_42.png)

Mensaje de error al intentar acceder a la carpeta de sucursal central desde sucursal norte

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_21_50_12.png)

desde la propiedades del disco C en el srv app se habilita la couta de disco con 2gb de limite

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_21_50_09.png)

esto se comprueba accediendo a la maquina cliente y observando el limite fijo

# D.

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_22_29_41.png)

agrego 4 impresorar genericas IBM (1 para cada sucursal)

![](E:\Maquinas%20virtuales\Proyecto%20final\SRV-APP01\VirtualBox_SRV-APP01_30_07_2026_22_35_35.png)

administrador de impresion con 4 impresoras correctamente agregadas

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_22_40_42.png)

captura desde una maquina cliente mostrando las 4 impresoras compartidas 

# E

omitido

# F

![](E:\Maquinas%20virtuales\Proyecto%20final\PC-NORTE01\VirtualBox_PC-NORTE01_30_07_2026_22_49_06.png)

acceso remoto exitoso desde sucursal norte hacia servidor app
