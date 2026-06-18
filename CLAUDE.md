# CLAUDE.md — Laboratorio de Redes 5TX (entrada para Claude Code)

Este repositorio sirve tanto para **OpenClaw** (que lee `AGENTS.md`) como para
**Claude Code** (que lee este `CLAUDE.md`). El contenido de fondo es el mismo: las
reglas, el orden de servicios y la red del laboratorio viven en `AGENTS.md` y se
importan aqui para no duplicar nada.

@AGENTS.md

---

## Notas especificas de Claude Code

### Como arrancar

1. Clona el repo en el servidor a configurar y entra en la carpeta:
   ```bash
   git clone https://github.com/ImEliasBtw/network-project-big-brain.git
   cd network-project-big-brain
   ```
2. Lanza Claude Code dentro de esa carpeta: `claude`. Al iniciar leera este
   `CLAUDE.md` (y con el, `AGENTS.md`) automaticamente.
3. Dile tu grupo, distro e interfaz. Ejemplo:
   > "Soy del Grupo 3. El servidor tiene Rocky Linux 9, interfaz ens33. Configura
   > mi servidor siguiendo `grupos/grupo-03.md`."

### Permisos y ejecucion

- La configuracion **modifica el sistema** (instala paquetes, edita `/etc`,
  arranca servicios) y casi todo requiere `sudo`. Claude Code pedira aprobacion
  por cada comando segun el modo de permisos activo.
- En una VM de laboratorio dedicada puedes acelerar con menos prompts usando un
  modo de auto-aceptacion (p. ej. lanzar con `--permission-mode acceptEdits` o
  pulsar el atajo de "auto-accept"). **Solo en la VM del lab**, nunca en una
  maquina con datos reales.
- Si un comando `sudo` se queda esperando contrasena, escribela tu en la terminal:
  el agente no la conoce.

### Como leer el repo (igual que cualquier agente)

1. `grupos/grupo-0N.md` → instrucciones autocontenidas de tu grupo (empieza aqui).
2. `servicios/SERVICIO.md` → detalle ampliado de un servicio puntual.
3. `distros/DISTRO.md` → comandos especificos de tu distribucion.

### Lo que NO debe hacer Claude Code

- No inventar ni cambiar IPs/dominios: la tabla del archivo de grupo es la unica
  fuente de verdad (la asigno el docente).
- No saltarse el orden de servicios (IP → DHCP → DNS → Web → FTP → SMTP).
- No tocar archivos de otros grupos al configurar el tuyo.

### Sugerencia: comando de verificacion

Al terminar, pidele a Claude Code que recorra el **Checklist final** del archivo
de tu grupo y ejecute cada comando de verificacion (`ip a`, `nslookup`, `curl`,
`systemctl status`, prueba de correo), reportando OK/FALLA por servicio.
