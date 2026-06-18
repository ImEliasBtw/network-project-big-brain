# Servicio DNS (BIND) — detalle ampliado

Resuelve los nombres del dominio del grupo (`www`, `ftp`, `mail`, `ns`) a la IP
del servidor. Web, FTP y SMTP dependen de el. Debe aceptar consultas de
**cualquier grupo** para las pruebas cruzadas de la defensa.

> Los valores concretos (dominio, IP, ultimo octeto para el PTR) estan en el
> archivo de tu grupo.

## Paquete, demonio y rutas por familia

| Aspecto       | Debian / Ubuntu              | RHEL (Rocky / Alma / Fedora) |
|---------------|------------------------------|------------------------------|
| Paquete       | `bind9 bind9utils`           | `bind bind-utils`            |
| Demonio       | `bind9`                      | `named`                      |
| Config zonas  | `/etc/bind/named.conf.local` | `/etc/named.conf`            |
| Zona directa  | `/etc/bind/db.DOMINIO`       | `/var/named/db.DOMINIO.zone` |
| Zona inversa  | `/etc/bind/db.192.168.28`    | `/var/named/192.168.28.zone` |
| Permisos      | no necesario                 | `chown named:named /var/named/*.zone` |

Zona inversa (origen): `28.168.192.in-addr.arpa`.

## Declaracion de zonas (Debian, `named.conf.local`)

```
zone "DOMINIO" {
    type master;
    file "/etc/bind/db.DOMINIO";
};

zone "28.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.28";
};
```

En `named.conf.options` (o `/etc/named.conf` en RHEL): `allow-query { any; };` y
`listen-on port 53 { any; };`, con `recursion no;`.

## Zona directa

```
$TTL 604800
@   IN  SOA ns.DOMINIO. admin.DOMINIO. (
            2026061801 ; Serial (incrementar en cada cambio)
            604800 86400 2419200 604800 )
@       IN  NS  ns.DOMINIO.
@       IN  MX  10 mail.DOMINIO.
ns      IN  A   IP_SERVIDOR
www     IN  A   IP_SERVIDOR
ftp     IN  A   IP_SERVIDOR
mail    IN  A   IP_SERVIDOR
```

## Zona inversa

```
$TTL 604800
@   IN  SOA ns.DOMINIO. admin.DOMINIO. (
            2026061801 604800 86400 2419200 604800 )
@       IN  NS  ns.DOMINIO.
OCTETO  IN  PTR ns.DOMINIO.
OCTETO  IN  PTR www.DOMINIO.
OCTETO  IN  PTR mail.DOMINIO.
```

`OCTETO` = ultimo numero de la IP del servidor (ej. 66 para 192.168.28.66).

## Validacion y arranque

```bash
sudo named-checkconf
sudo named-checkzone DOMINIO /etc/bind/db.DOMINIO
# Debian / Ubuntu
sudo systemctl enable --now bind9
# RHEL
sudo chown named:named /var/named/*.zone
sudo systemctl enable --now named
sudo firewall-cmd --add-service=dns --permanent && sudo firewall-cmd --reload
```

## Verificacion

```bash
nslookup www.DOMINIO 127.0.0.1     # debe devolver IP_SERVIDOR
nslookup IP_SERVIDOR 127.0.0.1     # debe devolver el nombre (PTR)
```

## Errores comunes

- Olvidar el punto final en los FQDN (`ns.DOMINIO.`) rompe la zona.
- No incrementar el serial tras editar → los cambios no se propagan.
- RHEL: zonas sin `chown named:named` o firewall cerrado.
