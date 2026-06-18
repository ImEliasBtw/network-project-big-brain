# Distro: Rocky Linux

Familia **RHEL**. Gestor `dnf`. Red por `nmcli`. Firewall y SELinux **activos por
defecto** — es la causa #1 de servicios que funcionan local pero no desde la red.

## Deteccion

```bash
cat /etc/os-release    # ID="rocky"
```

## IP estatica (nmcli)

```bash
nmcli con show                       # ver el nombre de la conexion (CONEXION)
sudo nmcli con mod "CONEXION" ipv4.addresses IP_SERVIDOR/27
sudo nmcli con mod "CONEXION" ipv4.gateway GATEWAY
sudo nmcli con mod "CONEXION" ipv4.dns 127.0.0.1
sudo nmcli con mod "CONEXION" ipv4.method manual
sudo nmcli con up "CONEXION"
```

## Paquetes por servicio

| Servicio | Paquete         | Servicio systemd | Config                       |
|----------|-----------------|------------------|------------------------------|
| DHCP     | `dhcp-server`   | `dhcpd`          | `/etc/dhcp/dhcpd.conf`       |
| DNS      | `bind bind-utils`| `named`         | `/etc/named.conf`            |
| Web      | `httpd`         | `httpd`          | `/etc/httpd/conf.d/`         |
| FTP      | `vsftpd`        | `vsftpd`         | `/etc/vsftpd/vsftpd.conf`    |
| SMTP     | `postfix mailx` | `postfix`        | `/etc/postfix/main.cf`       |

## Firewall (obligatorio tras cada servicio)

```bash
sudo firewall-cmd --add-service=dhcp --permanent
sudo firewall-cmd --add-service=dns  --permanent
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=ftp  --permanent
sudo firewall-cmd --add-service=smtp --permanent
sudo firewall-cmd --reload
```

## SELinux y permisos

- Web: `sudo chcon -R -t httpd_sys_content_t /var/www/DOMINIO`.
- DNS: zonas en `/var/named/` con `sudo chown named:named /var/named/*.zone`.
- En `/etc/named.conf`: `listen-on port 53 { any; };` y `allow-query { any; };`.

## Particularidades

- No existe `a2ensite`: el VirtualHost en `/etc/httpd/conf.d/` se carga solo.
- Zonas DNS en `/var/named/db.DOMINIO.zone` y `/var/named/192.168.28.zone`.
