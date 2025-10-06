#!/bin/sh
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
# rsync is 404ing on my machine so removing
#: ${PROTOCOLS:="https,rsync"}
: ${PROTOCOLS:="https"}

. /etc/os-release

if [ "${DEBUG}" = "true" ]; then
  set -x
fi

pacman_clear_cache () {
  if [ -x /usr/bin/paccache ]; then 
    paccache -rk1
  else
    yes Y|sudo pacman -Scc
  fi
  sudo touch "${CLEARED_CACHE_MARKER}"
}

update_mirrorlist () {
  set -x
  sudo reflector \
      --threads 8 \
      --delay 1 \
      --country US \
      --ipv4 \
      --verbose \
      --save "${MIRROR_LIST_LOCATION}" \
      --protocol "${PROTOCOLS}" \
      --sort rate \
      --download-timeout 4 \
      --connection-timeout 4 \
      --age 24 \
      --score 100 \
      --fastest 100 \
      --number 100 \
      --latest 100
  set +x
}

clear_update_placeholder () {
  sudo rm -f "${ROOT_UPDATED_MARKER}"
}

phile_czekr () {
  if [ "${DEBUG}" = "true" ]; then
    printf "If $1 is older than $2 days then run the function $3\n"
  fi
  filename=$1
  file_age_thresh=$(date -d "now - $2 days" +%s)
  function_to_run=$3
  if [ -f $filename ]; then
    file_age=$(sudo date -r "$filename" +%s)
  else
    file_age=$file_age_thresh
  fi

  # ...and then just use integer math:
  if [ $file_age -le $file_age_thresh ]; then
    $function_to_run
  else
    echo "$filename is up to date"
  fi
}

replace_mirrorlist () {
  if ! cmp "${MIRROR_LIST_LOCATION}" "/etc/pacman.d/mirrorlist" >/dev/null 2>&1
  then
    #TMP=$(mktemp -d)
    #sudo rsync --temp-dir /tmp/$TMP -av "$MIRROR_LIST_LOCATION" /etc/pacman.d/mirrorlist
    #rm -Rf $TMP
    sudo cp -v "${MIRROR_LIST_LOCATION}" "/etc/pacman.d/mirrorlist"
  fi
}

use_reflector () {
  if [ ! -f ${MIRROR_LIST_LOCATION} ]; then
    echo 'Mirrorlist cache not found'
    echo 'Using existing one to populate cache'
    cp -v /etc/pacman.d/mirrorlist "${MIRROR_LIST_LOCATION}" 
  fi
  phile_czekr "${MIRROR_LIST_LOCATION}" ${MIRROR_UPDATE_INTERVAL} update_mirrorlist
  replace_mirrorlist
}

loop_update_pacman () {
  looper=0
  returnCode=1
  while [ $looper -le 10 ]; do
    sudo ls -alh "${ROOT_UPDATED_MARKER}"
    returnCode=$?
    if [ $returnCode = 0 ]; then
      echo "# BREAK! update marker found, breaking looper at $looper loops"
      looper=11
      break
    else
      echo "### update marker not found, at $looper loops"
      looper=$((looper+1))
      update_pacman_core
    fi
  done
}

update_pacman () {
  if [ -f /var/cache/pacman/pkg/cache.lck ]; then
    echo The pacman cache file exists!
    echo Check to see if other pacman processes are running.
    echo If not `rm /var/cache/pacman/pkg/cache.lck` to clear this file.
    exit 1
  fi
  if [ ${PACMAN_LOOPER} ]; then
    loop_update_pacman
  else
    update_pacman_core
  fi
}

update_pacman_core () {
  returnCode=1
  if [ USE_POWERPILL = true ]; then
    sudo pacman -Sy --noconfirm
    if [ -f /usr/bin/powerpill ]; then
      sudo powerpill -Su --noconfirm
      returnCode=$?
    else
      echo 'Error power pill not found!'
      exit 1
    fi
  else
    sudo pacman -Syu --noconfirm
    returnCode=$?
  fi
  if [ $returnCode -eq 0 ]; then
    sudo touch "${ROOT_UPDATED_MARKER}"
  else
    sudo pacman -Sy --noconfirm ${ONE_RING_TO_RULE_THEM_ALL}
  fi
}

check_hooks () {
  if [ -f /etc/ssshutdown/hooks/in ]; then
    echo 'Found in hook'
    sudo bash /etc/ssshutdown/hooks/in
  fi
}

check_outhooks () {
  if [ -f /etc/ssshutdown/hooks/out ]; then
    echo 'Found out hook'
    sudo bash /etc/ssshutdown/hooks/out
  fi
}

pacman_update () {
  check_hooks
  use_reflector
  phile_czekr "${CLEARED_CACHE_MARKER}" "${SYSTEM_CLEARCACHE_INTERVAL}" pacman_clear_cache
  phile_czekr "${ROOT_UPDATED_MARKER}" "${SYSTEM_UPDATE_INTERVAL}" update_pacman
  check_outhooks
}

update_apt () {
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo touch "${ROOT_UPDATED_MARKER}"
}

apt_update () {
  phile_czekr "${ROOT_UPDATED_MARKER}" "${SYSTEM_UPDATE_INTERVAL}" update_apt
}

nix_update () {
  phile_czekr "${ROOT_UPDATED_MARKER}" "${SYSTEM_UPDATE_INTERVAL}" update_nix
}

update_nix () {
  if command_exists nx; then
    nx auto -f
  else
    echo nx is not installed
    exit 1
  fi
}

try_update () {
  if [ "${NAME}" = "Arch Linux" ]; then
    pacman_update
  elif [ "${NAME}" = "Ubuntu" || "${NAME}" = "Debian" || "${NAME}" = "Linux Mint" ]; then
    apt_update
  elif [ "${NAME}" = "NixOS" ]; then
    nix_update
  else
    echo "unknown os = ${NAME} bailing out!"
    exit 1
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

try_hibernate () {
  swapon_count=$(swapon|wc -l)
  if [ $swapon_count -gt 1 ]; then
    systemctl hibernate
  else
    echo 'No swap cannot hibernate!'; exit 1
  fi
}

try_hybrid () {
  systemctl hybrid-sleep
}

command_exists () {
  type "$1" &> /dev/null ;
}

powertop_auto_tune () {
  if command_exists powertop; then
    sudo powertop --auto-tune
  fi
}

cpufreqqr () {
  THIS_GOVERNOR=$1
  THIS_MAXFREQ=$2
  THIS_MINFREQ=$3
  if command_exists cpupower; then
    sudo cpupower frequency-set --min ${MINFREQ} --max ${MAXFREQ} --governor ${GOVERNOR}
    sudo cpupower frequency-info
  elif command_exists cpufreq-set; then
    CPU_COUNT=$(lscpu -p | grep -E -v '^#' | sort -u -t, -k 2,4 | wc -l)
    count_zero=0
    while [ ${count_zero} -lt ${CPU_COUNT} ]; do
      count_zero=$((count_zero+1))
      sudo cpufreq-set -c ${count_zero} -g ${GORVERNOR} --max ${MAXFREQ} --min ${MINFREQ}
      #sudo cpufreq-set -c $count_zero --max $MAXFREQ
      #sudo cpufreq-set -c $count_zero --min $MINFREQ
      #echo "cpu $i set to performance"
    done
    cpufreq-info
  fi
}

cleanring () {
  sudo killall gpg-agent
  set -eux
  sudo mv -v /etc/pacman.d/gnupg /tmp/
  sudo pacman-key --init
  sudo pacman-key --populate
  sudo pacman-key --refresh-key
  sudo systemctl restart gpg-agent@etc-pacman.d-gnupg.socket 
  sudo pacman -Sy archlinux-keyring
  sudo pacman -Su ncdu  
}
