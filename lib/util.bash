#!/bin/bash
: ${MIRROR_UPDATE_INTERVAL:=7}
: ${SYSTEM_UPDATE_INTERVAL:=1}
. /etc/os-release

update_mirrorlist () {
  mirrorlist_file='/etc/pacman.d/mirrorlist'
  sudo reflector \
      --threads 100 \
      --verbose \
      --save "$mirrorlist_file" \
      --sort rate \
      --age 24 \
      --latest 100
}

clear_all_placeholders () {
  sudo rm -f "/root/.updated"
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
  phile_czekr "/etc/pacman.d/mirrorlist" $MIRROR_UPDATE_INTERVAL update_mirrorlist
}

update_pacman () {
  sudo pacman -Sy
  if [[ -f /usr/bin/powerpill ]]; then
    sudo powerpill -Su --noconfirm
  else
    sudo pacman -Su --noconfirm
  fi
  sudo touch "/root/.updated"
}

pacman_update () {
  use_reflector
  phile_czekr "/root/.updated" $SYSTEM_UPDATE_INTERVAL update_pacman
}

update_apt () {
  apt-get update
  apt-get upgrade -y
  sudo touch "/root/.updated"
}

apt_update () {
  phile_czekr "/root/.updated" $SYSTEM_UPDATE_INTERVAL update_apt
}

try_update () {
  if [[ $NAME == "Arch Linux" ]]; then
    pacman_update
  elif [[ $NAME == "Ubuntu" || $NAME == "Ubuntu" ]]; then
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
