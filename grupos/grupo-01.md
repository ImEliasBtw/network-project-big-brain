---
grupo: 1
dominio: redes1-5TX.com.ni
ip_servidor: 192.168.28.2
gateway: 192.168.28.1
red: 192.168.28.0/27
mascara: 255.255.255.224
dhcp_inicio: 192.168.28.3
dhcp_fin: 192.168.28.30
broadcast: 192.168.28.31
distro: por detectar
---

# Configuracion del servidor — Grupo 1

Eres un agente de configuracion de sistemas Linux. Configura este servidor como
infraestructura de red para el **Grupo 1** de la seccion 5TX de Redes de
Computadoras, UNI. Sigue los pasos en el orden exacto en que aparecen: hay
dependencias entre servicios.

## Paso 0 — Detecta la distribucion

Antes de empezar, ejecuta y guarda el resultado:

```bash
cat /etc/os-release
ip a
```

- Si `ID` es `ubuntu` o `debian` → usa los bloques **Debian / Ubuntu**.
- Si `ID` es `rocky`, `almalinux` o `fedora` → usa los bloques **RHEL** y
  recuerda abrir el firewall al final de cada servicio.
- Anota el nombre de la interfaz de red (ej. `ens33`, `enp0s3`) y, en RHEL, el
  nombre de la conexion NetworkManager (`nmcli con show`). Donde el texto diga
  `INTERFAZ` o `CONEXION`, sustituye por el valor real de este servidor.

## Identidad de este servidor

| Parametro       | Valor |
|-----------------|-------|
| Grupo           | 1 |
| Dominio         | redes1-5TX.com.ni |
| Red             | 192.168.28.0/27 |
| Mascara         | 255.255.255.224 |
| Gateway         | 192.168.28.1 |
| IP del servidor | 192.168.28.2 |
| Rango DHCP      | 192.168.28.3 — 192.168.28.30 |
| Broadcast       | 192.168.28.31 |
| Hostnames DNS   | ns / www / ftp / mail . redes1-5TX.com.ni |

## Contexto del laboratorio (para pruebas cruzadas en la defensa)

Todos los grupos comparten la red fisica 192.168.28.0/23 y cada uno opera en su
subred /27. Tu DNS debe aceptar consultas de cualquier grupo.

| Grupo | Dominio | Red /27 | Gateway | IP Servidor | Rango DHCP |
|-------|---------|---------|---------|-------------|------------|
| 1 | redes1-5TX.com.ni | 192.168.28.0/27 | 192.168.28.1 | 192.168.28.2 | 192.168.28.3 - 192.168.28.30 |
| 2 | redes2-5TX.com.ni | 192.168.28.32/27 | 192.168.28.33 | 192.168.28.34 | 192.168.28.35 - 192.168.28.62 |
| 3 | redes3-5TX.com.ni | 192.168.28.64/27 | 192.168.28.65 | 192.168.28.66 | 192.168.28.67 - 192.168.28.94 |
| 4 | redes4-5TX.com.ni | 192.168.28.96/27 | 192.168.28.97 | 192.168.28.98 | 192.168.28.99 - 192.168.28.126 |
| 5 | redes5-5TX.com.ni | 192.168.28.128/27 | 192.168.28.129 | 192.168.28.130 | 192.168.28.131 - 192.168.28.158 |
| 6 | redes6-5TX.com.ni | 192.168.28.160/27 | 192.168.28.161 | 192.168.28.162 | 192.168.28.163 - 192.168.28.190 |
| 7 | redes7-5TX.com.ni | 192.168.28.192/27 | 192.168.28.193 | 192.168.28.194 | 192.168.28.195 - 192.168.28.222 |
| 8 | redes8-5TX.com.ni | 192.168.28.224/27 | 192.168.28.225 | 192.168.28.226 | 192.168.28.227 - 192.168.28.254 |

---

## Paso 1 — IP estatica del servidor

**Debian / Ubuntu** — crea/edita `/etc/netplan/01-redes.yaml`:

```yaml
network:
  version: 2
  ethernets:
    INTERFAZ:
      dhcp4: no
      addresses:
        - 192.168.28.2/27
      routes:
        - to: default
          via: 192.168.28.1
      nameservers:
        addresses: [127.0.0.1]
```

Aplica:

```bash
sudo netplan apply
```

**RHEL (Rocky / Alma / Fedora)** — usa nmcli (CONEXION = nombre de `nmcli con show`):

```bash
sudo nmcli con mod "CONEXION" ipv4.addresses 192.168.28.2/27
sudo nmcli con mod "CONEXION" ipv4.gateway 192.168.28.1
sudo nmcli con mod "CONEXION" ipv4.dns 127.0.0.1
sudo nmcli con mod "CONEXION" ipv4.method manual
sudo nmcli con up "CONEXION"
```

**Verificacion:** `ip a` debe mostrar `192.168.28.2/27` en la interfaz.

---

## Paso 2 — DHCP

Los clientes necesitan IP antes que nada.

**Debian / Ubuntu:**

```bash
sudo apt update && sudo apt install -y isc-dhcp-server
```

Edita `/etc/default/isc-dhcp-server` y pon la interfaz:

```
INTERFACESv4="INTERFAZ"
```

**RHEL:**

```bash
sudo dnf install -y dhcp-server
```

**Ambas familias** — contenido del archivo de configuracion DHCP
(`/etc/dhcp/dhcpd.conf`):

```
option domain-name "redes1-5TX.com.ni";
option domain-name-servers 192.168.28.2;
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 192.168.28.0 netmask 255.255.255.224 {
  range 192.168.28.3 192.168.28.30;
  option routers 192.168.28.1;
  option subnet-mask 255.255.255.224;
  option broadcast-address 192.168.28.31;
  option domain-name-servers 192.168.28.2;
  option domain-name "redes1-5TX.com.ni";
}
```

Inicia el servicio:

```bash
# Debian/Ubuntu
sudo systemctl enable --now isc-dhcp-server
# RHEL
sudo systemctl enable --now dhcpd
```

**Firewall (solo RHEL):**

```bash
sudo firewall-cmd --add-service=dhcp --permanent && sudo firewall-cmd --reload
```

**Verificacion:** `systemctl status isc-dhcp-server` (Debian) o
`systemctl status dhcpd` (RHEL) debe aparecer `active (running)`.

---

## Paso 3 — DNS (BIND)

Web, FTP y SMTP dependen del nombre de dominio.

**Debian / Ubuntu:**

```bash
sudo apt install -y bind9 bind9utils
```

Declara las zonas en `/etc/bind/named.conf.local`:

```
zone "redes1-5TX.com.ni" {
    type master;
    file "/etc/bind/db.redes1-5TX.com.ni";
};

zone "28.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.28";
};
```

En `/etc/bind/named.conf.options` permite consultas de todos los grupos:

```
options {
    directory "/var/cache/bind";
    allow-query { any; };
    recursion no;
};
```

Zona directa `/etc/bind/db.redes1-5TX.com.ni`:

```
$TTL 604800
@   IN  SOA ns.redes1-5TX.com.ni. admin.redes1-5TX.com.ni. (
            2026061801 ; Serial
            604800     ; Refresh
            86400      ; Retry
            2419200    ; Expire
            604800 )   ; Negative Cache TTL
;
@       IN  NS  ns.redes1-5TX.com.ni.
@       IN  MX  10 mail.redes1-5TX.com.ni.
ns      IN  A   192.168.28.2
www     IN  A   192.168.28.2
ftp     IN  A   192.168.28.2
mail    IN  A   192.168.28.2
```

Zona inversa `/etc/bind/db.192.168.28`:

```
$TTL 604800
@   IN  SOA ns.redes1-5TX.com.ni. admin.redes1-5TX.com.ni. (
            2026061801 ; Serial
            604800     ; Refresh
            86400      ; Retry
            2419200    ; Expire
            604800 )   ; Negative Cache TTL
;
@       IN  NS  ns.redes1-5TX.com.ni.
2      IN  PTR ns.redes1-5TX.com.ni.
2      IN  PTR www.redes1-5TX.com.ni.
2      IN  PTR mail.redes1-5TX.com.ni.
```

Verifica la sintaxis e inicia:

```bash
sudo named-checkconf
sudo named-checkzone redes1-5TX.com.ni /etc/bind/db.redes1-5TX.com.ni
sudo systemctl enable --now bind9
```

**RHEL:** el paquete es `bind bind-utils`, el demonio `named`, la config
`/etc/named.conf` y las zonas van en `/var/named/` (`db.redes1-5TX.com.ni.zone` y
`192.168.28.zone`). Tras crearlas:

```bash
sudo dnf install -y bind bind-utils
sudo chown named:named /var/named/*.zone
sudo systemctl enable --now named
sudo firewall-cmd --add-service=dns --permanent && sudo firewall-cmd --reload
```

En `/etc/named.conf` pon `listen-on port 53 { any; };` y
`allow-query { any; };` para las pruebas cruzadas.

**Verificacion:** `nslookup www.redes1-5TX.com.ni 127.0.0.1` debe devolver `192.168.28.2`.

---

## Paso 4 — Servidor Web (depende de DNS)

**Debian / Ubuntu:**

```bash
sudo apt install -y apache2
```

VirtualHost `/etc/apache2/sites-available/grupo-1.conf`:

```
<VirtualHost *:80>
    ServerName www.redes1-5TX.com.ni
    ServerAlias redes1-5TX.com.ni
    DocumentRoot /var/www/redes1-5TX.com.ni
    ErrorLog ${APACHE_LOG_DIR}/grupo1_error.log
    CustomLog ${APACHE_LOG_DIR}/grupo1_access.log combined
</VirtualHost>
```

Contenido y activacion:

```bash
sudo mkdir -p /var/www/redes1-5TX.com.ni
echo "<h1>Grupo 1 — redes1-5TX.com.ni</h1><p>Servidor web operativo.</p>" | sudo tee /var/www/redes1-5TX.com.ni/index.html
sudo a2ensite grupo-1.conf
sudo systemctl reload apache2
```

**RHEL:** paquete `httpd`, config en `/etc/httpd/conf.d/grupo-1.conf`
(mismo VirtualHost pero usa `ErrorLog logs/grupo1_error.log`). No hace falta
`a2ensite`.

```bash
sudo dnf install -y httpd
sudo mkdir -p /var/www/redes1-5TX.com.ni
echo "<h1>Grupo 1 — redes1-5TX.com.ni</h1><p>Servidor web operativo.</p>" | sudo tee /var/www/redes1-5TX.com.ni/index.html
sudo chcon -R -t httpd_sys_content_t /var/www/redes1-5TX.com.ni
sudo systemctl enable --now httpd
sudo firewall-cmd --add-service=http --permanent && sudo firewall-cmd --reload
```

**Verificacion:** `curl http://www.redes1-5TX.com.ni` debe mostrar el HTML del Grupo 1.

---

## Paso 5 — FTP (depende de DNS, usa usuarios del sistema)

**Debian / Ubuntu:**

```bash
sudo apt install -y vsftpd
```

Config `/etc/vsftpd.conf`:

```
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pam_service_name=vsftpd
```

Crea usuario de prueba e inicia:

```bash
sudo useradd -m ftpgrupo1
echo "ftpgrupo1:redes1" | sudo chpasswd
sudo systemctl enable --now vsftpd
```

**RHEL:** la config es `/etc/vsftpd/vsftpd.conf` (mismo contenido).

```bash
sudo dnf install -y vsftpd
sudo systemctl enable --now vsftpd
sudo firewall-cmd --add-service=ftp --permanent && sudo firewall-cmd --reload
```

**Verificacion:** `systemctl status vsftpd` debe estar `active (running)`;
prueba `ftp ftp.redes1-5TX.com.ni` con el usuario creado.

---

## Paso 6 — SMTP (Postfix; depende de DNS para el registro MX)

**Debian / Ubuntu:**

```bash
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix mailutils
```

**RHEL:**

```bash
sudo dnf install -y postfix mailx
```

**Ambas familias** — parametros clave en `/etc/postfix/main.cf`:

```
myhostname = mail.redes1-5TX.com.ni
mydomain = redes1-5TX.com.ni
myorigin = $mydomain
inet_interfaces = all
inet_protocols = ipv4
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = 192.168.28.0/27, 127.0.0.0/8
home_mailbox = Maildir/
```

Inicia:

```bash
sudo systemctl enable --now postfix
# Solo RHEL:
sudo firewall-cmd --add-service=smtp --permanent && sudo firewall-cmd --reload
```

**Verificacion:** `echo "Test" | mail -s "Prueba Grupo 1" root@localhost` y
revisa `/var/mail/` o `~/Maildir/`.

---

## Rutas de archivos — tabla para la defensa

| Servicio | Debian / Ubuntu | RHEL (Rocky / Alma / Fedora) |
|----------|-----------------|------------------------------|
| Red (IP) | `/etc/netplan/01-redes.yaml` | `nmcli con mod` (sin archivo manual) |
| DHCP     | `/etc/dhcp/dhcpd.conf` | `/etc/dhcp/dhcpd.conf` |
| DNS conf | `/etc/bind/named.conf.local` | `/etc/named.conf` |
| DNS directa | `/etc/bind/db.redes1-5TX.com.ni` | `/var/named/db.redes1-5TX.com.ni.zone` |
| DNS inversa | `/etc/bind/db.192.168.28` | `/var/named/192.168.28.zone` |
| Web      | `/etc/apache2/sites-available/grupo-1.conf` | `/etc/httpd/conf.d/grupo-1.conf` |
| Web raiz | `/var/www/redes1-5TX.com.ni/` | `/var/www/redes1-5TX.com.ni/` |
| FTP      | `/etc/vsftpd.conf` | `/etc/vsftpd/vsftpd.conf` |
| SMTP     | `/etc/postfix/main.cf` | `/etc/postfix/main.cf` |

## Checklist final

- [ ] `ip a` muestra 192.168.28.2/27
- [ ] DHCP entrega IPs en el rango 192.168.28.3 — 192.168.28.30
- [ ] `nslookup www.redes1-5TX.com.ni 127.0.0.1` devuelve 192.168.28.2
- [ ] `curl http://www.redes1-5TX.com.ni` responde
- [ ] `systemctl status vsftpd` activo
- [ ] correo de prueba entregado
- [ ] (RHEL) firewall abierto para dhcp, dns, http, ftp, smtp
