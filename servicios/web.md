# Servicio Web (Apache) — detalle ampliado

Sirve la pagina del grupo en `http://www.DOMINIO`. Depende de que el DNS resuelva
`www`.

> Los valores concretos (dominio, numero de grupo) estan en el archivo de tu
> grupo.

## Paquete y rutas por familia

| Aspecto        | Debian / Ubuntu                              | RHEL (Rocky / Alma / Fedora) |
|----------------|----------------------------------------------|------------------------------|
| Paquete        | `apache2`                                    | `httpd`                      |
| Servicio       | `apache2`                                    | `httpd`                      |
| Config sitio   | `/etc/apache2/sites-available/grupo-N.conf`  | `/etc/httpd/conf.d/grupo-N.conf` |
| Activar sitio  | `a2ensite grupo-N.conf`                      | no necesario                 |
| Raiz web       | `/var/www/DOMINIO/`                          | `/var/www/DOMINIO/`          |
| SELinux        | no necesario                                 | `chcon -R -t httpd_sys_content_t /var/www/DOMINIO` |

## VirtualHost

```
<VirtualHost *:80>
    ServerName www.DOMINIO
    ServerAlias DOMINIO
    DocumentRoot /var/www/DOMINIO
    ErrorLog ${APACHE_LOG_DIR}/grupoN_error.log
    CustomLog ${APACHE_LOG_DIR}/grupoN_access.log combined
</VirtualHost>
```

En RHEL usa `ErrorLog logs/grupoN_error.log` (relativo a `/var/log/httpd`).

## Instalacion y contenido

```bash
# Debian / Ubuntu
sudo apt install -y apache2
sudo mkdir -p /var/www/DOMINIO
echo "<h1>Grupo N — DOMINIO</h1>" | sudo tee /var/www/DOMINIO/index.html
sudo a2ensite grupo-N.conf
sudo systemctl reload apache2

# RHEL
sudo dnf install -y httpd
sudo mkdir -p /var/www/DOMINIO
echo "<h1>Grupo N — DOMINIO</h1>" | sudo tee /var/www/DOMINIO/index.html
sudo chcon -R -t httpd_sys_content_t /var/www/DOMINIO
sudo systemctl enable --now httpd
sudo firewall-cmd --add-service=http --permanent && sudo firewall-cmd --reload
```

## Verificacion

```bash
curl http://www.DOMINIO       # debe mostrar el HTML del grupo
```

## Errores comunes

- 404/sitio por defecto: olvidaste `a2ensite` (Debian) o el `ServerName`.
- RHEL: pagina vacia o 403 → falta `chcon` (SELinux) o el firewall bloquea `http`.
