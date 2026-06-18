# Distro: AlmaLinux

Familia **RHEL**, binariamente compatible con Rocky Linux. Gestor `dnf`, red por
`nmcli`, firewall y SELinux **activos por defecto**. Procede exactamente igual que
en Rocky Linux.

## Deteccion

```bash
cat /etc/os-release    # ID="almalinux"
```

## IP estatica (nmcli)

```bash
nmcli con show
sudo nmcli con mod "CONEXION" ipv4.addresses IP_SERVIDOR/27
sudo nmcli con mod "CONEXION" ipv4.gateway GATEWAY
sudo nmcli con mod "CONEXION" ipv4.dns 127.0.0.1
sudo nmcli con mod "CONEXION" ipv4.method manual
sudo nmcli con up "CONEXION"
```

## Paquetes por servicio

| Servicio | Paquete          | Servicio systemd | Config                    |
|----------|------------------|------------------|---------------------------|
| DHCP     | `dhcp-server`    | `dhcpd`          | `/etc/dhcp/dhcpd.conf`    |
| DNS      | `bind bind-utils`| `named`          | `/etc/named.conf`         |
| Web      | `httpd`          | `httpd`          | `/etc/httpd/conf.d/`      |
| FTP      | `vsftpd`         | `vsftpd`         | `/etc/vsftpd/vsftpd.conf` |
| SMTP     | `postfix mailx`  | `postfix`        | `/etc/postfix/main.cf`    |

## Firewall (tras cada servicio)

```bash
sudo firewall-cmd --add-service={dhcp,dns,http,ftp,smtp} --permanent
sudo firewall-cmd --reload
```

## SELinux y permisos

- Web: `chcon -R -t httpd_sys_content_t /var/www/DOMINIO`.
- DNS: `chown named:named /var/named/*.zone`; zonas en `/var/named/`.
- `/etc/named.conf`: `listen-on port 53 { any; };`, `allow-query { any; };`.

## Particularidades

- Sin `a2ensite` (VirtualHost en `/etc/httpd/conf.d/` se carga automaticamente).
- Identica a Rocky para fines de este laboratorio.
