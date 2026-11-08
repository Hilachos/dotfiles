#!/usr/bin/env bash
# captura.sh — capturas de pantalla con grim + slurp
# Uso: captura.sh [area|pantalla]
set -euo pipefail

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/captura_$(date +%Y-%m-%d_%H-%M-%S).png"
mode="${1:-area}"

case "$mode" in
  area)
    region="$(slurp)" || exit 0   # Esc = cancelar sin error
    grim -g "$region" "$file"
    ;;
  pantalla)
    grim "$file"
    ;;
  *)
    echo "Uso: $(basename "$0") [area|pantalla]" >&2
    exit 1
    ;;
esac

wl-copy < "$file"
notify-send -i "$file" "Captura guardada" "$(basename "$file") · copiada al portapapeles"
