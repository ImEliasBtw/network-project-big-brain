# Servicio DHCP — detalle ampliado

Entrega direcciones IP automaticas a los clientes de la subred del grupo. Es el
**primer servicio** (los clientes necesitan IP antes que nada).

> Los valores concretos (red, rango, gateway, broadcast) estan en el archivo de
> tu grupo. Aqui se explica el servicio en general.

## Paquete y servicio por familia

| Aspecto    | Debian / Ubuntu          | RHEL (Rocky / Alma / Fedora) |
|------------|--------------------------|------------------------------|
| Paquete    | `isc-dhcp-server`        | `dhcp-server`                |
| Servicio   | `isc-dhcp-server`        | `dhcpd`                      |
| Interfaz   | `/etc/default/isc-dhcp-server` | automatico             |
| Config     | `/etc/dhcp/dhcpd.conf`   | `/etc/dhcp/dhcpd.conf`       |

## Instalacion

```bash
# Debian / Ubuntu
sudo apt install -y isc-dhcp-server
# RHEL
sudo dnf install -y dhcp-server
```

En Debian/Ubuntu, declara la interfaz en `/etc/default/isc-dhcp-server`:

```
INTERFACESv4="INTERFAZ"
```

## Estructura del dhcpd.conf

```
option domain-name "DOMINIO";
option domain-name-servers IP_SERVIDOR;
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet RED_ID netmask 255.255.255.224 {
  range DHCP_INICIO DHCP_FIN;
  option routers GATEWAY;
  option subnet-mask 255.255.255.224;
  option broadcast-address BROADCAST;
  option domain-name-servers IP_SERVIDOR;
  option domain-name "DOMINIO";
}
```

## Arranque

```bash
# Debian / Ubuntu
sudo systemctl enable --now isc-dhcp-server
# RHEL
sudo systemctl enable --now dhcpd
sudo firewall-cmd --add-service=dhcp --permanent && sudo firewall-cmd --reload
```

## Verificacion

- `systemctl status isc-dhcp-server` / `systemctl status dhcpd` → `active`.
- Un cliente en la misma red debe recibir una IP del rango definido.
- Revisa concesiones: `cat /var/lib/dhcp/dhcpd.leases` (Debian) o
  `/var/lib/dhcpd/dhcpd.leases` (RHEL).

## Errores comunes

- Servicio no arranca: `authoritative;` ausente o `subnet` que no coincide con la
  red de la interfaz.
- RHEL: el firewall bloquea DHCP → abre el servicio `dhcp`.
