# Distro: Fedora

Familia **RHEL**, pero mas reciente que Rocky/Alma. Gestor `dnf`, red por `nmcli`,
firewall y SELinux **activos por defecto**. Mismas rutas que Rocky/Alma con
detalles propios de versiones nuevas.

## Deteccion

```bash
cat /etc/os-release    # ID=fedora
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
| SMTP     | `postfix`        | `postfix`        | `/etc/postfix/main.cf`    |

> Nota: en Fedora la utilidad de correo a veces es `s-nail`; si `mailx` no existe,
> instala `sudo dnf install -y s-nail`.

## Firewall (tras cada servicio)

```bash
sudo firewall-cmd --add-service={dhcp,dns,http,ftp,smtp} --permanent
sudo firewall-cmd --reload
```

## SELinux y permisos

- Web: `chcon -R -t httpd_sys_content_t /var/www/DOMINIO` (SELinux suele estar en
  `enforcing`).
- DNS: `chown named:named /var/named/*.zone`; zonas en `/var/named/`.
- `/etc/named.conf`: `listen-on port 53 { any; };`, `allow-query { any; };`.

## Particularidades

- Versiones de paquetes mas nuevas; revisa rutas si algo cambia entre releases.
- Sin `a2ensite`. Por defecto Fedora puede no traer servidor grafico (server edition).
