# Speeder
[! [logo] (https://github.dev/Quamagi/Speeder/blob/main/logo.jpg)

Speeder es un script de Windows que puede ayudar a mejorar la velocidad de Internet. El script realiza los siguientes cambios en la configuración de TCP/IP:

* Habilita TCP Chimney Offload, una función que puede descargar ciertas tareas de procesamiento TCP/IP al adaptador de red.
* Desactiva las heurísticas TCP, que son algoritmos que Windows utiliza para ajustar dinámicamente la configuración de TCP.
* Establece el nivel de ajuste automático de TCP en "normal", que es el equilibrio predeterminado entre el rendimiento y la estabilidad.
* Establece el proveedor de congestión TCP en CTCP, un algoritmo de control de congestión más nuevo que puede mejorar el rendimiento en ciertos escenarios.

**Instalación**

Para instalar Speeder, descarga el archivo ZIP del repositorio de GitHub. Una vez descargado, descomprime el archivo y copia el script `Speeder.bat` a una ubicación accesible desde el símbolo del sistema.

**Uso**

Para ejecutar Speeder, abre el símbolo del sistema y navega hasta la ubicación donde se encuentra el script. A continuación, escribe el siguiente comando:

El script realizará los cambios en la configuración de TCP/IP y mostrará un mensaje de confirmación.

Recomendaciones

Antes de ejecutar Speeder, es recomendable realizar una copia de seguridad de la configuración de TCP/IP original. Para ello, abre el símbolo del sistema y escribe el siguiente comando:

netsh int tcp show global > backup.txt

Esto creará un archivo de texto llamado backup.txt que contiene la configuración de TCP/IP actual.

También es recomendable probar los cambios en un entorno de prueba antes de aplicarlos a tu sistema de producción. Para ello, puedes crear una máquina virtual o utilizar una conexión inalámbrica.

Compatibilidad

Speeder es compatible con la mayoría de los adaptadores de red. Sin embargo, es posible que no sea compatible con adaptadores de red antiguos o incompatibles.

Licencia

Speeder está bajo la licencia MIT.

Créditos

Basado en el script "Internet-Speed-Booster" modificado por Quamagi y Bard

Los créditos se han añadido a la sección "Instalación". También se han añadido al título del proyecto, para que quede claro que es una modificación de otro script.

Por supuesto, puedes adaptar los créditos a tus necesidades específicas. Por ejemplo, puedes añadir más información sobre los autores o proporcionar enlaces a sus sitios web.
