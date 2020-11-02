#!/bin/bash
: ${MIRROR_UPDATE_INTERVAL:=7}
: ${SYSTEM_UPDATE_INTERVAL:=1}
: ${SYSTEM_CLEARCACHE_INTERVAL:=30}
: ${CLEARED_CACHE_MARKER:="/var/cache/pacman/.clearedcache"}
: ${ROOT_UPDATED_MARKER:="/root/.updated"}
: ${MIRROR_LIST_LOCATION:="/etc/pacman.d/mirrorlist"}

. /etc/os-release
if [[ $DEBUG == true ]]; then
  set -x
fi

pacman_clear_cache () {
  yes Y|sudo pacman -Scc
  sudo touch "$CLEARED_CACHE_MARKER"
}

update_mirrorlist () {
  mirrorlist_file="$MIRROR_LIST_LOCATION"
  sudo reflector \
      --threads 100 \
      --verbose \
      --protocol https \
      --save "$mirrorlist_file" \
      --sort rate \
      --age 24 \
      --latest 100
}

clear_all_placeholders () {
  sudo rm -f "$ROOT_UPDATED_MARKER"
}

phile_czekr () {
  if [[ $DEBUG == true ]]; then
    printf "If $1 is older than $2 days then run the function $3\n"
  fi
  filename=$1
  file_age_thresh=$(date -d "now - $2 days" +%s)
  function_to_run=$3
  file_age=$(sudo date -r "$filename" +%s)

  # ...and then just use integer math:
  if (( file_age <= file_age_thresh )); then
    $function_to_run
  else
    echo "$filename is up to date"
  fi
}

use_reflector () {
  phile_czekr "$MIRROR_LIST_LOCATION" $MIRROR_UPDATE_INTERVAL update_mirrorlist
}

update_pacman () {
  sudo pacman -Sy
  if [[ -f /usr/bin/powerpill ]]; then
    sudo powerpill -Su --noconfirm
  else
    sudo pacman -Su --noconfirm
  fi
  sudo touch "$ROOT_UPDATED_MARKER"
}

check_hooks () {
  if [[ -f /etc/ssshutdown/hooks/in ]]; then
    echo 'Found in hook'
    sudo bash /etc/ssshutdown/hooks/in
  fi
}

check_outhooks () {
  if [[ -f /etc/ssshutdown/hooks/out ]]; then
    echo 'Found out hook'
    sudo bash /etc/ssshutdown/hooks/out
  fi
}

pacman_update () {
  use_reflector
  check_hooks
  phile_czekr "$CLEARED_CACHE_MARKER" "$SYSTEM_CLEARCACHE_INTERVAL" pacman_clear_cache
  phile_czekr "$ROOT_UPDATED_MARKER" "$SYSTEM_UPDATE_INTERVAL" update_pacman
  check_outhooks
}

update_apt () {
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo touch "$ROOT_UPDATED_MARKER"
}

apt_update () {
  phile_czekr "$ROOT_UPDATED_MARKER" "$SYSTEM_UPDATE_INTERVAL" update_apt
}

try_update () {
  if [[ $NAME == "Arch Linux" ]]; then
    pacman_update
  elif [[ $NAME == "Ubuntu" || $NAME == "Debian" || $NAME == "Linux Mint" ]]; then
    apt_update
  fi
}

try_shutdown () {
  sudo poweroff
}

try_sleep () {
  systemctl suspend
}

try_reboot () {
  sudo reboot
}

try_suspend () {
  systemctl suspend
}
