export PATH="$HOME/.local/bin:$PATH"
#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# ===== Arrancar Hyprland al iniciar sesión en tty1 =====
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
    export GTK_THEME=Adwaita:dark
    exec start-hyprland
fi
