# Distro: Debian

Familia **Debian** (base de Ubuntu). Gestor `apt`. Identica a Ubuntu Server salvo
detalles menores.

## Deteccion

```bash
cat /etc/os-release    # ID=debian
```

## IP estatica

Debian moderno (12+) tambien usa `netplan` o, segun instalacion,
`/etc/network/interfaces`. Si existe `/etc/netplan/`, usa netplan como en Ubuntu:

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

Si usa el esquema clasico, en `/etc/network/interfaces`:

```
auto INTERFAZ
iface INTERFAZ inet static
    address IP_SERVIDOR
    netmask 255.255.255.224
    gateway GATEWAY
```

## Paquetes por servicio

| Servicio | Paquete            | Servicio systemd  | Config                          |
|----------|--------------------|-------------------|---------------------------------|
| DHCP     | `isc-dhcp-server`  | `isc-dhcp-server` | `/etc/dhcp/dhcpd.conf`          |
| DNS      | `bind9 bind9utils` | `bind9`           | `/etc/bind/named.conf.local`    |
| Web      | `apache2`          | `apache2`         | `/etc/apache2/sites-available/` |
| FTP      | `vsftpd`           | `vsftpd`          | `/etc/vsftpd.conf`              |
| SMTP     | `postfix`          | `postfix`         | `/etc/postfix/main.cf`          |

## Particularidades

- Igual que Ubuntu: `a2ensite`, zonas en `/etc/bind/db.*`, sin SELinux.
- Puede requerir `sudo apt update` antes de instalar.
- El usuario quiza no esta en `sudoers` por defecto: usar `su -` si hace falta.
