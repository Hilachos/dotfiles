#!/usr/bin/env bash
# actualizar.sh — actualiza Arch (repos + AUR) de forma segura
# Uso: actualizar.sh
set -euo pipefail

# ── Colores Tokyo Night Moon ──────────────────────────────
AZUL=$'\e[38;2;130;170;255m'
VERDE=$'\e[38;2;195;232;141m'
NARANJA=$'\e[38;2;255;150;108m'
ROJO=$'\e[38;2;255;117;127m'
RESET=$'\e[0m'

# ── Funciones de mensajes ─────────────────────────────────
info()  { printf '%s==>%s %s\n' "$AZUL" "$RESET" "$1"; }
ok()    { printf '%s ✔%s %s\n' "$VERDE" "$RESET" "$1"; }
aviso() { printf '%s !%s %s\n' "$NARANJA" "$RESET" "$1"; }
error() { printf '%s ✘%s %s\n' "$ROJO" "$RESET" "$1" >&2; }

# ── 1. Conexión ───────────────────────────────────────────
if ! ping -c1 -W3 archlinux.org &>/dev/null; then
    error "Sin conexión a internet."
    exit 1
fi

# ── 2. Actualizaciones pendientes (sin tocar nada) ────────
info "Buscando actualizaciones..."
repo=$(checkupdates 2>/dev/null | wc -l || true)
aur=$(paru -Qua 2>/dev/null | wc -l || true)
total=$(( repo + aur ))

if (( total == 0 )); then
    ok "El sistema ya está al día."
    exit 0
fi
info "Pendientes: ${repo} de repositorios y ${aur} del AUR."

read -rp "¿Actualizar ahora? [s/N] " resp
[[ "${resp,,}" == "s" ]] || { info "Cancelado."; exit 0; }

# ── 3. Repositorios oficiales (snap-pac crea las snapshots) ─
sudo pacman -Syu

# ── 4. AUR (paru te enseña los PKGBUILD: ¡revísalos!) ─────
if (( aur > 0 )); then
    paru -Sua
fi

# ── 5. Limpieza de caché: guarda las 2 últimas versiones ──
sudo paccache -rk2

# ── 6. Resumen ────────────────────────────────────────────
info "Últimas snapshots:"
sudo snapper -c root list | tail -n 4

instalado=$(pacman -Q linux | awk '{print $2}' | sed 's/\.arch/-arch/')
en_uso=$(uname -r)
if [[ "$instalado" != "$en_uso" ]]; then
    aviso "Kernel nuevo (${instalado}). En uso: ${en_uso}. Reinicia cuando puedas."
    notify-send -u critical "Actualización completada" "Kernel nuevo: reinicia cuando puedas"
else
    ok "Actualización completada."
    notify-send "Actualización completada" "${total} paquetes actualizados"
fi
