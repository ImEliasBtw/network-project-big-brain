# Repo Redes 5TX — Laboratorio de Configuracion

Repositorio de configuracion para el Trabajo de Fin de Curso de Redes de
Computadoras. Seccion 5TX — UNI.

Cada grupo configura un servidor Linux con DHCP, DNS, Web, FTP y SMTP usando un
agente LLM que lee las instrucciones de este repositorio.

## Estructura

```
.
├── AGENTS.md            ← El agente lo lee primero al iniciar sesion
├── README.md            ← Este archivo (instrucciones para humanos)
├── grupos/              ← Instrucciones completas y autocontenidas por grupo
│   ├── grupo-01.md ... grupo-08.md
├── servicios/           ← Detalle ampliado por servicio
│   ├── dhcp.md  dns.md  web.md  ftp.md  smtp.md
└── distros/             ← Comandos especificos por distribucion
    ├── ubuntu-server.md  debian.md  rocky-linux.md  almalinux.md  fedora.md
```

## Como usar este repo (para cada grupo)

### 1. Clonar

```bash
git clone https://github.com/ImEliasBtw/network-project-big-brain.git
```

### 2. Abrir el agente y apuntarlo al repo

El agente leera `AGENTS.md` automaticamente al iniciar.

### 3. Decirle al agente tu grupo

> "Soy del Grupo 3. Mi servidor tiene Ubuntu Server 22.04. La interfaz de red es
> ens33. Configura mi servidor."

El agente lee `grupos/grupo-03.md` y ejecuta todo paso a paso.

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

## Coordinacion entre grupos

El DNS de todos los grupos debe estar activo para la defensa (pruebas cruzadas).
Si terminaste, avisa al coordinador de la seccion.
