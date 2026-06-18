# Distro: Ubuntu Server

Familia **Debian**. Gestor de paquetes `apt`. Red por `netplan`.

## Deteccion

```bash
cat /etc/os-release    # ID=ubuntu
```

## IP estatica (netplan)

`/etc/netplan/01-redes.yaml`:

```yaml
network:
  version: 2
  ethernets:
    INTERFAZ:
      dhcp4: no
      addresses: [IP_SERVIDOR/27]
      routes:
        - to: default
          via: GATEWAY
      nameservers:
        addresses: [127.0.0.1]
```

```bash
sudo netplan apply
```

## Paquetes por servicio

| Servicio | Paquete            | Servicio systemd  | Config                              |
|----------|--------------------|-------------------|-------------------------------------|
| DHCP     | `isc-dhcp-server`  | `isc-dhcp-server` | `/etc/dhcp/dhcpd.conf`              |
| DNS      | `bind9 bind9utils` | `bind9`           | `/etc/bind/named.conf.local`        |
| Web      | `apache2`          | `apache2`         | `/etc/apache2/sites-available/`     |
| FTP      | `vsftpd`           | `vsftpd`          | `/etc/vsftpd.conf`                  |
| SMTP     | `postfix`          | `postfix`         | `/etc/postfix/main.cf`              |

## Particularidades

- Activar sitio web: `sudo a2ensite grupo-N.conf && sudo systemctl reload apache2`.
- Interfaz DHCP: `INTERFACESv4="INTERFAZ"` en `/etc/default/isc-dhcp-server`.
- Firewall (ufw) opcional y normalmente inactivo: no suele bloquear.
- No requiere SELinux ni `chown` especial para BIND.
- Zonas DNS en `/etc/bind/db.*`.
