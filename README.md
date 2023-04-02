# arch-install-script
Script sencillo en bash para una rápida instalación de Arch Linux. Tiene 0
personalización por lo que no recomiendo usarlo a otras personas. Pero puede
servir como base para lo que quiran hacer.

## Uso
Siempre se me olvida como usar este programa. Ya era hora de que agregue un
readme para las veces en que lo tengo que usar.

1. Iniciar ArchLinux desde la iso como lo haríamos normalmente.
2. Seleccionar la rama que queremos usar del programa, puede ser main o test,
ejecutaremos este comando:
```
export rama="main"
```
3. Descargar script-1.sh, después él mismo descargará los demás cuando los necesite:
```
curl -LJO raw.githubusercontent.com/pinguin-frosch/arch-install-script/$rama/install-1.sh
```
4. Ejecutar el script con bash:
```
bash install-1.sh
```
