# Repo Redes 5TX — Laboratorio de Configuracion

Repositorio de configuracion para el Trabajo de Fin de Curso de Redes de
Computadoras. Seccion 5TX — UNI.

Cada grupo configura un servidor Linux con DHCP, DNS, Web, FTP y SMTP usando un
agente LLM que lee las instrucciones de este repositorio.

Funciona con **OpenClaw** (lee `AGENTS.md`) y con **Claude Code** (lee
`CLAUDE.md`). Ambos comparten el mismo contenido: `CLAUDE.md` importa `AGENTS.md`.

## Estructura

```
.
├── AGENTS.md            ← Contexto para OpenClaw (fuente de verdad de las reglas)
├── CLAUDE.md            ← Contexto para Claude Code (importa AGENTS.md + notas propias)
├── README.md            ← Este archivo (instrucciones para humanos)
├── grupos/              ← Instrucciones completas y autocontenidas por grupo
│   ├── grupo-01.md ... grupo-08.md
├── servicios/           ← Detalle ampliado por servicio
│   ├── dhcp.md  dns.md  web.md  ftp.md  smtp.md
└── distros/             ← Comandos especificos por distribucion
    ├── ubuntu-server.md  debian.md  rocky-linux.md  almalinux.md  fedora.md
```

## Como usar este repo (para cada grupo)

### 1. Clonar (igual para ambos agentes)

```bash
git clone https://github.com/ImEliasBtw/network-project-big-brain.git
cd network-project-big-brain
```

### 2a. Con OpenClaw

Abre OpenClaw apuntando al repo. Leera `AGENTS.md` automaticamente al iniciar.

### 2b. Con Claude Code

Dentro de la carpeta del repo, ejecuta `claude`. Leera `CLAUDE.md` (que importa
`AGENTS.md`) automaticamente. Ojo: la configuracion usa `sudo` y modifica el
sistema; aprueba los comandos o usa un modo de auto-aceptacion **solo en la VM
del laboratorio**. Ver detalles en `CLAUDE.md`.

### 3. Decirle al agente tu grupo

> "Soy del Grupo 3. Mi servidor tiene Ubuntu Server 22.04. La interfaz de red es
> ens33. Configura mi servidor."

El agente (OpenClaw o Claude Code) lee `grupos/grupo-03.md` y ejecuta todo paso a
paso.

## Grupos y direcciones

| Grupo | Dominio           | IP Servidor    |
|-------|-------------------|----------------|
| 1     | redes1-5TX.com.ni | 192.168.28.2   |
| 2     | redes2-5TX.com.ni | 192.168.28.34  |
| 3     | redes3-5TX.com.ni | 192.168.28.66  |
| 4     | redes4-5TX.com.ni | 192.168.28.98  |
| 5     | redes5-5TX.com.ni | 192.168.28.130 |
| 6     | redes6-5TX.com.ni | 192.168.28.162 |
| 7     | redes7-5TX.com.ni | 192.168.28.194 |
| 8     | redes8-5TX.com.ni | 192.168.28.226 |

Mascara universal: `255.255.255.224` (`/27`). Red base del laboratorio:
`192.168.28.0/23`.

## Orden de configuracion (hay dependencias)

1. IP estatica → 2. DHCP → 3. DNS → 4. Web → 5. FTP → 6. SMTP.

## Verificacion (opcional)

Tras configurar el servidor puedes comprobar que todo quedo bien con el script de
solo lectura `tools/verificar.sh`. **No instala ni modifica nada**: solo consulta
el estado actual y reporta OK/FALLA por servicio.

```bash
chmod +x tools/verificar.sh
./tools/verificar.sh 3        # tu numero de grupo
./tools/verificar.sh          # sin argumento: intenta autodetectar por la IP
```

Comprueba IP estatica, DHCP, DNS (directo, inverso, MX), Web, FTP y SMTP. Devuelve
codigo de salida 0 si todo pasa y 1 si algo falla, asi que sirve tambien para una
revision rapida el dia de la defensa. Requiere `dig`/`nslookup` y `curl` (vienen
con los servicios instalados); si faltan, esos chequeos se omiten con aviso.

## Coordinacion entre grupos

El DNS de todos los grupos debe estar activo para la defensa (pruebas cruzadas).
Si terminaste, avisa al coordinador de la seccion.
