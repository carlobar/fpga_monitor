FPGA monitores un visor de señales implementado en Verilog.

La estructura de los directorios es:
/rtl		Contiene la entidad principal y el archivo UCF para la FPGA spartan 3E xc3s500e.
/cores		Código en Verilog de los componentes que usa el visualizador.
/test		Archivos para simular el visualizador.


En el archivo system.v se hace un ejemplo de como se pueden ver las señales de un contador de 0 a 5 en forma ascendente o descendente (dependiendo del valor de la entrada sw[3]). La captura de datos se habilita con sw[0]. Por medio del a perilla de la tarjeta (rotary pushbutton) se cambia la fase del reloj de muestreo. Las señales se pueden visualizar en un monitor.
