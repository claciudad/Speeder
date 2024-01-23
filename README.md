# Speeder

Speeder es un script de Windows que puede ayudar a mejorar la velocidad de Internet. El script realiza los siguientes cambios en la configuración de TCP/IP:

* Habilita TCP Chimney Offload, una función que puede descargar ciertas tareas de procesamiento TCP/IP al adaptador de red.
* Desactiva las heurísticas TCP, que son algoritmos que Windows utiliza para ajustar dinámicamente la configuración de TCP.
* Establece el nivel de ajuste automático de TCP en "normal", que es el equilibrio predeterminado entre el rendimiento y la estabilidad.
* Establece el proveedor de congestión TCP en CTCP, un algoritmo de control de congestión más nuevo que puede mejorar el rendimiento en ciertos escenarios.

**Instalación**

Para instalar Speeder, descarga el archivo ZIP del repositorio de GitHub. Una vez descargado, descomprime el archivo y copia el script `Speeder.bat` a una ubicación accesible desde el símbolo del sistema.

**Uso**

Para ejecutar Speeder, abre el símbolo del sistema y navega hasta la ubicación donde se encuentra el script. A continuación, escribe el siguiente comando:

