# Servicio SMTP (Postfix) — detalle ampliado

Servidor de correo del grupo. Depende del DNS para el registro MX
(`mail.DOMINIO`). Es el ultimo servicio en configurarse.

> Los valores concretos (dominio, red /27) estan en el archivo de tu grupo.

## Paquete por familia

| Aspecto   | Debian / Ubuntu        | RHEL (Rocky / Alma / Fedora) |
|-----------|------------------------|------------------------------|
| Paquetes  | `postfix mailutils`    | `postfix mailx`              |
| Servicio  | `postfix`              | `postfix`                    |
| Config    | `/etc/postfix/main.cf` | `/etc/postfix/main.cf`       |

## Instalacion

```bash
# Debian / Ubuntu (no interactivo)
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix mailutils
# RHEL
sudo dnf install -y postfix mailx
```

## Parametros clave en main.cf

```
myhostname = mail.DOMINIO
mydomain = DOMINIO
myorigin = $mydomain
inet_interfaces = all
inet_protocols = ipv4
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = RED_ID/27, 127.0.0.0/8
home_mailbox = Maildir/
```

## Arranque

```bash
sudo systemctl enable --now postfix
# Solo RHEL
sudo firewall-cmd --add-service=smtp --permanent && sudo firewall-cmd --reload
```

## Verificacion

```bash
echo "Cuerpo de prueba" | mail -s "Prueba Grupo N" root@localhost
# revisa el buzon
ls ~/Maildir/new/    # o  /var/mail/
```

Tambien puedes probar el registro MX:

```bash
nslookup -type=mx DOMINIO 127.0.0.1
```

## Errores comunes

- MX no resuelve → DNS incompleto (falta el registro `MX` o `mail A`).
- Correo no sale de la red → `inet_interfaces = all` y `mynetworks` correctos.
- RHEL: firewall sin el servicio `smtp`.
