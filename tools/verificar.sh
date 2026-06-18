#!/usr/bin/env bash
#
# verificar.sh — Verificacion (solo lectura) del servidor de un grupo.
# Laboratorio de Redes 5TX — UNI. Uso OPCIONAL: no instala ni modifica nada,
# solo comprueba el estado actual y reporta OK/FALLA por servicio.
#
# Uso:
#   ./verificar.sh <grupo>     # ej: ./verificar.sh 3
#   ./verificar.sh             # intenta autodetectar el grupo por la IP del host
#
# Codigo de salida: 0 si todo pasa, 1 si algun chequeo falla.
#
set -u

# ----------------------------------------------------------------------------
# Tabla canonica de direccionamiento — fuente de verdad (no inventar valores).
# Campos: dominio|red|gateway|ip_servidor|dhcp_inicio|dhcp_fin|broadcast
# ----------------------------------------------------------------------------
datos_grupo() {
  case "$1" in
    1) echo "redes1-5TX.com.ni|192.168.28.0|192.168.28.1|192.168.28.2|192.168.28.3|192.168.28.30|192.168.28.31" ;;
    2) echo "redes2-5TX.com.ni|192.168.28.32|192.168.28.33|192.168.28.34|192.168.28.35|192.168.28.62|192.168.28.63" ;;
    3) echo "redes3-5TX.com.ni|192.168.28.64|192.168.28.65|192.168.28.66|192.168.28.67|192.168.28.94|192.168.28.95" ;;
    4) echo "redes4-5TX.com.ni|192.168.28.96|192.168.28.97|192.168.28.98|192.168.28.99|192.168.28.126|192.168.28.127" ;;
    5) echo "redes5-5TX.com.ni|192.168.28.128|192.168.28.129|192.168.28.130|192.168.28.131|192.168.28.158|192.168.28.159" ;;
    6) echo "redes6-5TX.com.ni|192.168.28.160|192.168.28.161|192.168.28.162|192.168.28.163|192.168.28.190|192.168.28.191" ;;
    7) echo "redes7-5TX.com.ni|192.168.28.192|192.168.28.193|192.168.28.194|192.168.28.195|192.168.28.222|192.168.28.223" ;;
    8) echo "redes8-5TX.com.ni|192.168.28.224|192.168.28.225|192.168.28.226|192.168.28.227|192.168.28.254|192.168.28.255" ;;
    *) return 1 ;;
  esac
}
MASK="255.255.255.224"

# ----------------------------------------------------------------------------
# Presentacion
# ----------------------------------------------------------------------------
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_OK=$'\033[32m'; C_FAIL=$'\033[31m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_OK=""; C_FAIL=""; C_DIM=""; C_RST=""
fi
PASS=0; FAILN=0
ok()   { printf '[ %sOK%s ]  %-18s %s%s%s\n'   "$C_OK"   "$C_RST" "$1" "$C_DIM" "$2" "$C_RST"; PASS=$((PASS+1)); }
fail() { printf '[%sFALLA%s] %-18s %s%s%s\n'    "$C_FAIL" "$C_RST" "$1" "$C_DIM" "$2" "$C_RST"; FAILN=$((FAILN+1)); }
warn() { printf '[ %s--%s ]  %-18s %s%s%s\n'    "$C_DIM"  "$C_RST" "$1" "$C_DIM" "$2" "$C_RST"; }
have() { command -v "$1" >/dev/null 2>&1; }

# ----------------------------------------------------------------------------
# Deteccion de distro -> familia (debian | rhel)
# ----------------------------------------------------------------------------
FAMILIA="desconocida"
if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}${ID_LIKE:-}" in
    *ubuntu*|*debian*) FAMILIA="debian" ;;
    *rhel*|*fedora*|*rocky*|*almalinux*|*centos*) FAMILIA="rhel" ;;
  esac
fi

# ----------------------------------------------------------------------------
# Helpers de bajo nivel
# ----------------------------------------------------------------------------
svc_active() {  # devuelve 0 si CUALQUIERA de los servicios dados esta activo
  local s
  for s in "$@"; do
    if have systemctl && systemctl is-active --quiet "$s" 2>/dev/null; then
      ACTIVE_SVC="$s"; return 0
    fi
  done
  return 1
}

port_listening() {  # $1 = numero de puerto
  if have ss; then        ss -ltnH 2>/dev/null | grep -qE "[:.]$1[[:space:]]"
  elif have netstat; then  netstat -ltn 2>/dev/null | grep -qE "[:.]$1[[:space:]]"
  else return 2; fi
}

resolve_a() {   # $1 = nombre -> imprime la primera IP de la respuesta
  if have dig;       then dig +short A "$1" @127.0.0.1 2>/dev/null | grep -E '^[0-9.]+$' | head -n1
  elif have nslookup; then nslookup "$1" 127.0.0.1 2>/dev/null | awk '/^Address: ?/{a=$2} END{print a}'
  fi
}
resolve_ptr() { # $1 = ip -> imprime el FQDN
  if have dig;       then dig +short -x "$1" @127.0.0.1 2>/dev/null | head -n1
  elif have nslookup; then nslookup "$1" 127.0.0.1 2>/dev/null | sed -n 's/.*name = //p' | head -n1
  fi
}
resolve_mx() {  # $1 = dominio -> imprime el host del MX
  if have dig;       then dig +short MX "$1" @127.0.0.1 2>/dev/null | awk '{print $2}' | head -n1
  elif have nslookup; then nslookup -type=mx "$1" 127.0.0.1 2>/dev/null | sed -n 's/.*mail exchanger = //p' | head -n1
  fi
}

# ----------------------------------------------------------------------------
# Resolucion del numero de grupo
# ----------------------------------------------------------------------------
GRUPO="${1:-}"
if [[ -z "$GRUPO" ]]; then
  # autodetectar por la IP del servidor presente en el host
  mias=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
  for g in 1 2 3 4 5 6 7 8; do
    ipsrv=$(datos_grupo "$g" | cut -d'|' -f4)
    if grep -qx "$ipsrv" <<<"$mias"; then GRUPO="$g"; break; fi
  done
fi
if ! [[ "$GRUPO" =~ ^[1-8]$ ]]; then
  echo "Uso: $0 <grupo 1-8>   (o sin argumento para autodetectar por IP)" >&2
  [[ -n "$GRUPO" ]] && echo "Grupo invalido: '$GRUPO' (solo existen los grupos 1 a 8)." >&2
  exit 2
fi

IFS='|' read -r DOM RED GW IP_SRV DHCP_I DHCP_F BC <<<"$(datos_grupo "$GRUPO")"

echo   "== Verificacion Grupo $GRUPO — $DOM ($IP_SRV) =="
printf '%sFamilia detectada: %s | red %s/27 | mascara %s%s\n\n' \
  "$C_DIM" "$FAMILIA" "$RED" "$MASK" "$C_RST"

# Aviso de herramientas que faltan (no hacen fallar, pero limitan chequeos)
have dig || have nslookup || warn "DNS" "ni 'dig' ni 'nslookup' disponibles; los chequeos DNS se omiten"
have curl || warn "Web" "'curl' no disponible; el chequeo web se omite"

# ----------------------------------------------------------------------------
# 1. IP estatica
# ----------------------------------------------------------------------------
if have ip && ip -4 -o addr show scope global 2>/dev/null | grep -q "$IP_SRV/27"; then
  iface=$(ip -4 -o addr show scope global | awk -v ip="$IP_SRV/27" '$0 ~ ip {print $2; exit}')
  ok "IP estatica" "$IP_SRV/27 presente en ${iface:-interfaz}"
else
  fail "IP estatica" "no se encontro $IP_SRV/27 en ninguna interfaz"
fi

# ----------------------------------------------------------------------------
# 2. DHCP
# ----------------------------------------------------------------------------
if svc_active isc-dhcp-server dhcpd; then
  if [[ -r /etc/dhcp/dhcpd.conf ]] && grep -q "$RED" /etc/dhcp/dhcpd.conf 2>/dev/null; then
    ok "DHCP" "$ACTIVE_SVC activo; subred $RED en dhcpd.conf"
  else
    fail "DHCP" "$ACTIVE_SVC activo pero la subred $RED no aparece en /etc/dhcp/dhcpd.conf"
  fi
else
  fail "DHCP" "servicio inactivo (isc-dhcp-server / dhcpd)"
fi

# ----------------------------------------------------------------------------
# 3. DNS (directo, inverso, MX) — contra 127.0.0.1
# ----------------------------------------------------------------------------
if have dig || have nslookup; then
  got=$(resolve_a "www.$DOM")
  [[ "$got" == "$IP_SRV" ]] && ok "DNS directo" "www.$DOM -> $IP_SRV" \
                            || fail "DNS directo" "esperaba $IP_SRV, obtuve '${got:-vacio}'"

  ptr=$(resolve_ptr "$IP_SRV")
  if [[ "$ptr" == *"$DOM"* ]]; then ok "DNS inverso" "$IP_SRV -> $ptr"
  else fail "DNS inverso" "PTR de $IP_SRV no apunta a $DOM (obtuve '${ptr:-vacio}')"; fi

  mx=$(resolve_mx "$DOM")
  if [[ "$mx" == *"mail.$DOM"* ]]; then ok "DNS MX" "$mx"
  else fail "DNS MX" "MX de $DOM no es mail.$DOM (obtuve '${mx:-vacio}')"; fi
fi

# ----------------------------------------------------------------------------
# 4. Web
# ----------------------------------------------------------------------------
if have curl; then
  code=$(curl -s -m 5 -o /dev/null -w '%{http_code}' "http://www.$DOM" 2>/dev/null)
  [[ "$code" == "200" ]] && ok "Web" "http://www.$DOM responde 200" \
                         || fail "Web" "http://www.$DOM devolvio '${code:-sin respuesta}'"
fi

# ----------------------------------------------------------------------------
# 5. FTP
# ----------------------------------------------------------------------------
if svc_active vsftpd; then
  if port_listening 21; then ok "FTP" "vsftpd activo; puerto 21 escuchando"
  else fail "FTP" "vsftpd activo pero el puerto 21 no escucha"; fi
else
  fail "FTP" "vsftpd inactivo"
fi

# ----------------------------------------------------------------------------
# 6. SMTP
# ----------------------------------------------------------------------------
if svc_active postfix; then
  if port_listening 25; then ok "SMTP" "postfix activo; puerto 25 escuchando"
  else fail "SMTP" "postfix activo pero el puerto 25 no escucha"; fi
else
  fail "SMTP" "postfix inactivo"
fi

# ----------------------------------------------------------------------------
# Resumen
# ----------------------------------------------------------------------------
echo "--------------------------------------------------"
total=$((PASS+FAILN))
if [[ "$FAILN" -eq 0 ]]; then
  printf 'Resultado: %s%d/%d OK%s — servidor del Grupo %s verificado.\n' "$C_OK" "$PASS" "$total" "$C_RST" "$GRUPO"
  exit 0
else
  printf 'Resultado: %d/%d OK — %s%d con fallas%s. Revisa los [FALLA] de arriba.\n' "$PASS" "$total" "$C_FAIL" "$FAILN" "$C_RST"
  exit 1
fi
