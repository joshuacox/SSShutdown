#!/bin/bash
: ${MIRROR_UPDATE_INTERVAL:=7}
: ${SYSTEM_UPDATE_INTERVAL:=1}
: ${SYSTEM_CLEARCACHE_INTERVAL:=30}
: ${CLEARED_CACHE_MARKER:="/var/cache/pacman/.clearedcache"}
: ${ROOT_UPDATED_MARKER:="/root/.updated"}
#: ${MIRROR_LIST_LOCATION:="/etc/pacman.d/mirrorlist"}
: ${MIRROR_LIST_LOCATION:="/var/cache/pacman/mirrorlist"}
: ${ONE_RING_TO_RULE_THEM_ALL:="archlinux-keyring gnome-keyring alpine-keyring debian-archive-keyring ubuntu-keyring"}
: ${PACMAN_LOOPER:=true}
: ${USE_POWERPILL:=false}

. /etc/os-release
if [[ $DEBUG == true ]]; then
  set -x
fi

pacman_clear_cache () {
  if [[ -x /usr/bin/paccache ]]; then 
    paccache -rk1
  else
    yes Y|sudo pacman -Scc
  fi
  sudo touch "$CLEARED_CACHE_MARKER"
}

update_mirrorlist () {
  sudo reflector \
      --threads 100 \
      --verbose \
      --save "$MIRROR_LIST_LOCATION" \
      --protocol https \
      --sort rate \
      --age 24 \
      --score 100 \
      --fastest 100 \
      --latest 100
}

clear_update_placeholder () {
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
  if [[ ! -f $MIRROR_LIST_LOCATION ]]; then
    echo 'Mirrorlist cache not found'
    echo 'Using existing one to populate cache'
    cp -v /etc/pacman.d/mirrorlist "$MIRROR_LIST_LOCATION" 
  fi
  phile_czekr "$MIRROR_LIST_LOCATION" $MIRROR_UPDATE_INTERVAL update_mirrorlist
  if ! cmp "$MIRROR_LIST_LOCATION" "/etc/pacman.d/mirrorlist" >/dev/null 2>&1
  then
    #TMP=$(mktemp -d)
    #sudo rsync --temp-dir /tmp/$TMP -av "$MIRROR_LIST_LOCATION" /etc/pacman.d/mirrorlist
    #rm -Rf $TMP
    sudo cp -v "$MIRROR_LIST_LOCATION" "/etc/pacman.d/mirrorlist"
  fi
}

loop_update_pacman () {
  looper=0
  returnCode=1
  while [[ $looper -le 10 ]]; do
    sudo ls -alh "$ROOT_UPDATED_MARKER"
    returnCode=$?
    if [[ $returnCode == 0 ]]; then
      echo "# BREAK! update marker found, breaking looper at $looper loops"
      looper=11
      break
    else
      echo "### update marker not found, at $looper loops"
      ((++looper))
      update_pacman_core
    fi
  done
}

update_pacman () {
  if [[ -f /var/cache/pacman/pkg/cache.lck ]]; then
    echo The pacman cache file exists!
    echo Check to see if other pacman processes are running.
    echo If not `rm /var/cache/pacman/pkg/cache.lck` to clear this file.
    exit 1
  fi
  if [[ $PACMAN_LOOPER ]]; then
    loop_update_pacman
  else
    update_pacman_core
  fi
}

update_pacman_core () {
  returnCode=1
  if [[ -f /usr/bin/powerpill && USE_POWERPILL == true ]]; then
    sudo pacman -Sy --noconfirm
    sudo powerpill -Su --noconfirm
    returnCode=$?
  else
    sudo pacman -Syu --noconfirm
    returnCode=$?
  fi
  if [[ $returnCode == 0 ]]; then
    sudo touch "$ROOT_UPDATED_MARKER"
  else
    sudo pacman -Sy --noconfirm $ONE_RING_TO_RULE_THEM_ALL
  fi
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
  check_hooks
  use_reflector
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
