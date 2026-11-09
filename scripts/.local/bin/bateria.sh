#!/usr/bin/env bash
# bateria.sh — estado y salud de la batería (lee /sys)
# Uso: bateria.sh
set -euo pipefail

AZUL=$'\e[38;2;130;170;255m'; VERDE=$'\e[38;2;195;232;141m'
NARANJA=$'\e[38;2;255;150;108m'; ROJO=$'\e[38;2;255;117;127m'
MORADO=$'\e[38;2;192;153;255m'; RESET=$'\e[0m'

# ── Localizar la batería (BAT0, BAT1...) ──────────────────
bat=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' | head -n1)
if [[ -z "$bat" ]]; then
    echo "No se encontró ninguna batería." >&2
    exit 1
fi

leer() { cat "$bat/$1" 2>/dev/null || echo 0; }

# Unos portátiles usan energy_* (µWh) y otros charge_* (µAh)
if [[ -r "$bat/energy_full" ]]; then pre=energy; else pre=charge; fi

capacidad=$(leer capacity)
estado=$(leer status)
ahora=$(leer "${pre}_now")
lleno=$(leer "${pre}_full")
diseno=$(leer "${pre}_full_design")
ciclos=$(leer cycle_count)
potencia=$(leer power_now)

# ── Traducir el estado ────────────────────────────────────
case "$estado" in
    Charging)       estado_es="Cargando" ;;
    Discharging)    estado_es="Descargando" ;;
    Full)           estado_es="Llena" ;;
    "Not charging") estado_es="Enchufada (sin cargar)" ;;
    *)              estado_es="$estado" ;;
esac

# ── Salud: capacidad actual vs. capacidad de fábrica ──────
if (( diseno > 0 )); then
    salud=$(( lleno * 100 / diseno ))
else
    salud=0
fi

if   (( salud >= 80 )); then color_salud=$VERDE
elif (( salud >= 60 )); then color_salud=$NARANJA
else                          color_salud=$ROJO
fi

# ── Informe ───────────────────────────────────────────────
printf '\n%s 󰁹  Batería%s  (%s)\n\n' "$MORADO" "$RESET" "$(basename "$bat")"
printf '  %-16s %s%%\n' "Carga:" "$capacidad"
printf '  %-16s %s\n'   "Estado:" "$estado_es"

if [[ "$estado" == "Discharging" && "$pre" == "energy" ]] && (( potencia > 0 )); then
    minutos=$(( ahora * 60 / potencia ))
    printf '  %-16s %dh %02dmin\n' "Tiempo restante:" $(( minutos / 60 )) $(( minutos % 60 ))
    printf '  %-16s %d.%d W\n'     "Consumo:" $(( potencia / 1000000 )) $(( potencia / 100000 % 10 ))
fi

printf '  %-16s %s%s%%%s\n' "Salud:" "$color_salud" "$salud" "$RESET"
(( ciclos > 0 )) && printf '  %-16s %s\n' "Ciclos:" "$ciclos"
printf '\n%sPerfil de energía:%s %s\n\n' "$AZUL" "$RESET" "$(powerprofilesctl get 2>/dev/null || echo '?')"
