# Servicio FTP (vsftpd) — detalle ampliado

Permite transferir archivos al servidor autenticando con usuarios del sistema.
Depende de DNS para `ftp.DOMINIO`.

> Los valores concretos estan en el archivo de tu grupo.

## Rutas por familia

| Aspecto   | Debian / Ubuntu     | RHEL (Rocky / Alma / Fedora) |
|-----------|---------------------|------------------------------|
| Paquete   | `vsftpd`            | `vsftpd`                     |
| Servicio  | `vsftpd`            | `vsftpd`                     |
| Config    | `/etc/vsftpd.conf`  | `/etc/vsftpd/vsftpd.conf`    |

## Configuracion (vsftpd.conf)

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

## Instalacion, usuario y arranque

```bash
# Debian / Ubuntu
sudo apt install -y vsftpd
# RHEL
sudo dnf install -y vsftpd

# usuario de prueba (ajusta el nombre por grupo)
sudo useradd -m ftpgrupoN
echo "ftpgrupoN:redesN" | sudo chpasswd

sudo systemctl enable --now vsftpd
# Solo RHEL
sudo firewall-cmd --add-service=ftp --permanent && sudo firewall-cmd --reload
```

## Verificacion

```bash
systemctl status vsftpd           # active (running)
ftp ftp.DOMINIO                   # login con el usuario creado
```

## Errores comunes

- `500 OOPS: vsftpd: refusing to run with writable root` → faltó
  `allow_writeable_chroot=YES`.
- RHEL: conexion rechazada desde la red → firewall sin el servicio `ftp`.
- FTP activo requiere permitir tambien el puerto 20/datos segun el modo.
