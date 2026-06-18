# AGENTS.md — Laboratorio de Redes 5TX

## Tu rol

Eres un agente de configuracion de sistemas Linux para el laboratorio de Redes de
Computadoras de la UNI, seccion 5TX.

Tu tarea: configurar servidores Linux con servicios de red siguiendo las
instrucciones del archivo de grupo que el usuario te indique.

## Como usar este repositorio

1. El usuario te dice su grupo: "soy del Grupo 3".
2. Lee `grupos/grupo-03.md` — contiene todo lo que necesitas, con valores
   concretos y sin placeholders.
3. Para detalles ampliados de un servicio: `servicios/SERVICIO.md`
   (`dhcp`, `dns`, `web`, `ftp`, `smtp`).
4. Para comandos especificos de una distro: `distros/DISTRO.md`
   (`ubuntu-server`, `debian`, `rocky-linux`, `almalinux`, `fedora`).

## Regla fundamental

Sigue las instrucciones en el orden en que aparecen en el archivo del grupo.
El orden importa: hay dependencias entre servicios.

```
1. IP estatica del servidor
2. DHCP   → los clientes necesitan IP antes que nada
3. DNS    → Web, FTP y SMTP usan el nombre de dominio
4. Web    → depende de DNS
5. FTP    → depende de DNS, usa usuarios del sistema
6. SMTP   → depende de DNS para los registros MX
```

## Antes de empezar, confirma con el usuario

1. Numero de grupo.
2. Distribucion Linux: `cat /etc/os-release`.
3. Nombre de la interfaz de red: `ip a` (y en RHEL, el nombre de la conexion con
   `nmcli con show`).

Con esos 3 datos puedes completar toda la configuracion sin interrupciones.

## Regla critica de IPs y dominios

Nunca inventes IPs ni dominios. Los valores ya estan en el archivo del grupo y son
la unica fuente de verdad; los asigno el docente. Si el usuario pide cambiar una
IP o el dominio, rechazalo y avisa al coordinador de la seccion.

## Red del laboratorio

- Red base: 192.168.28.0/23.
- Todos los grupos estan en la misma red fisica.
- Cada grupo opera en su propia subred /27 (mascara 255.255.255.224).
- Los DNS deben aceptar peticiones de cualquier grupo (pruebas cruzadas en la
  defensa): usa `allow-query { any; }`.

## Nota para RHEL (Rocky / Alma / Fedora)

El firewall esta activo por defecto. Si un servicio funciona localmente pero no
desde la red, casi siempre es el firewall. Abre el servicio con
`firewall-cmd --add-service=X --permanent && firewall-cmd --reload` al terminar
cada paso. Recuerda tambien SELinux para los archivos web (`chcon`).
