#!/bin/bash
: ${MIRROR_UPDATE_INTERVAL:=7}
: ${SYSTEM_UPDATE_INTERVAL:=1}
: ${DEBUG:=false}

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

update_pacman () {
  sudo pacman -Sy
  sudo powerpill -Su --noconfirm
  sudo touch "/root/.updated"
}

phile_czekr () {
  if [[ $DEBUG == true ]]; then
    printf "If $1 is older than $2 days then run the function $3\n"
  fi
  filename=$1
  file_age_thresh=$(date -d "now - $2 days" +%s)
  function_to_run=$3
  file_age=$(date -r "$filename" +%s)
  
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

pacman_update () {
  phile_czekr "/root/.updated" $SYSTEM_UPDATE_INTERVAL update_pacman
}

try_shutdown () {
  sudo poweroff
}

try_reboot () {
  sudo reboot 
}
