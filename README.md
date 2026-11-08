# 🌙 dotfiles — Arch Linux + Hyprland

Configuración personal de mi portátil **HP EliteBook 6 G1i**, instalado a mano desde cero.

## Sistema
| Capa | Elección |
|---|---|
| Distro | Arch Linux (instalación manual, sin archinstall) |
| Cifrado | LUKS2 (argon2id) |
| Sistema de ficheros | Btrfs con subvolúmenes + snapper (snapshots en cada pacman) |
| Arranque | systemd-boot + UKI |
| Compositor | Hyprland (config en Lua) |
| Barra | waybar |
| Terminal | kitty |
| Lanzador | wofi |
| Notificaciones | mako |
| Bloqueo | hyprlock + hypridle |
| Firewall | nftables (policy drop) |
| Paleta | Tokyo Night Moon |

## Estructura
Gestionado con **GNU Stow**: cada carpeta es un paquete que se enlaza en `$HOME`.

```bash
git clone git@github.com:Hilachos/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ hypr waybar kitty wofi mako gtk scripts bash
```

## Atajos principales
| Atajo | Acción |
|---|---|
| `SUPER + Q` | Terminal |
| `SUPER + R` | Lanzador |
| `SUPER + E` | Gestor de archivos |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + SHIFT + X` | Captura de un área |
| `SUPER + SHIFT + P` | Captura de pantalla completa |
