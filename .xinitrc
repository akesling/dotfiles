xautolock -time 15 -locker "gnome-screensaver-command --lock"

# Be sure to include X defaults for urxvt
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
