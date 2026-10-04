#!/usr/bin/env bash
: ${MIRROR_UPDATE_INTERVAL:=7}
: ${SYSTEM_UPDATE_INTERVAL:=1}
: ${SYSTEM_CLEARCACHE_INTERVAL:=30}
: ${ROOT_UPDATED_MARKER:="/root/.updated"}
: ${ONE_RING_TO_RULE_THEM_ALL:="archlinux-keyring gnome-keyring alpine-keyring debian-archive-keyring ubuntu-keyring"}
: ${PACMAN_LOOPER:=true}
: ${USE_POWERPILL:=false}
: ${PROTOCOLS:="https"}
: ${REFLECTOR_COUNTRY:="US"}
: ${APT_UPGRADE_TYPE:="upgrade"}

if [ -f /etc/os-release ]; then
  . /etc/os-release
fi

is_arch () {
  [ "${NAME:-}" = "Arch Linux" ] || [ "${ID:-}" = "arch" ] || [ "${ID:-}" = "omarchy" ] || [ "${ID:-}" = "endeavouros" ] || [ "${ID:-}" = "manjaro" ] || [[ "${ID_LIKE:-}" =~ arch ]]
}

is_debian () {
  [ "${ID:-}" = "debian" ] || [ "${ID:-}" = "ubuntu" ] || [ "${ID:-}" = "linuxmint" ] || [ "${ID:-}" = "Linux Mint" ] || [ "${ID:-}" = "pop" ] || [ "${ID:-}" = "elementary" ] || [ "${ID:-}" = "kali" ] || [ "${ID:-}" = "zorin" ] || [ "${ID:-}" = "raspbian" ] || [[ "${ID_LIKE:-}" =~ debian ]] || [[ "${ID_LIKE:-}" =~ ubuntu ]]
}

is_redhat () {
  [ "${ID:-}" = "rhel" ] || [ "${ID:-}" = "fedora" ] || [ "${ID:-}" = "centos" ] || [ "${ID:-}" = "rocky" ] || [ "${ID:-}" = "almalinux" ] || [ "${ID:-}" = "ol" ] || [ "${ID:-}" = "amzn" ] || [[ "${ID_LIKE:-}" =~ (rhel|fedora|centos) ]]
}

is_suse () {
  [[ "${ID:-}" =~ opensuse ]] || [ "${ID:-}" = "sles" ] || [[ "${ID_LIKE:-}" =~ suse ]]
}

is_nixos () {
  [ "${NAME:-}" = "NixOS" ] || [ "${ID:-}" = "nixos" ]
}

# Distro-appropriate default cache markers
if is_arch; then
  : ${CLEARED_CACHE_MARKER:="/var/cache/pacman/.clearedcache"}
  : ${MIRROR_LIST_LOCATION:="/var/cache/pacman/mirrorlist"}
elif is_debian; then
  : ${CLEARED_CACHE_MARKER:="/var/cache/apt/.clearedcache"}
elif is_redhat; then
  : ${CLEARED_CACHE_MARKER:="/var/cache/dnf/.clearedcache"}
else
  : ${CLEARED_CACHE_MARKER:="/var/cache/.ssshutdown_clearedcache"}
fi

if [ "${DEBUG}" = "true" ]; then
  set -x
fi

command_exists () {
  type "$1" &> /dev/null
}

touch_marker () {
  local target="$1"
  local parent
  parent=$(dirname "$target")
  if [ ! -d "$parent" ]; then
    sudo mkdir -p "$parent"
  fi
  sudo touch "$target"
}

clear_update_placeholder () {
  sudo rm -f "${ROOT_UPDATED_MARKER}"
}

phile_czekr () {
  if [ "${DEBUG}" = "true" ]; then
    printf "If %s is older than %s days then run the function %s\n" "$1" "$2" "$3"
  fi
  local filename="$1"
  local file_age_thresh
  file_age_thresh=$(date -d "now - $2 days" +%s)
  local function_to_run="$3"
  local file_age
  if [ -f "$filename" ]; then
    file_age=$(sudo date -r "$filename" +%s)
  else
    file_age=$file_age_thresh
  fi

  # ...and then just use integer math:
  if [ "$file_age" -le "$file_age_thresh" ]; then
    $function_to_run
  else
    echo "$filename is up to date"
  fi
}

check_hooks () {
  if [ -f /etc/ssshutdown/hooks/in ]; then
    echo 'Executing pre-update hook (/etc/ssshutdown/hooks/in)...'
    sudo bash /etc/ssshutdown/hooks/in
  fi
}

check_outhooks () {
  if [ -f /etc/ssshutdown/hooks/out ]; then
    echo 'Executing post-update hook (/etc/ssshutdown/hooks/out)...'
    sudo bash /etc/ssshutdown/hooks/out
  fi
}

check_reboot_required () {
  if [ -f /var/run/reboot-required ]; then
    echo "=========================================================="
    echo " [NOTICE] A system reboot is required to complete updates."
    if [ -f /var/run/reboot-required.pkgs ]; then
      echo " Packages requiring reboot:"
      sed 's/^/  - /' /var/run/reboot-required.pkgs
    fi
    echo "=========================================================="
  elif command_exists needs-restarting; then
    if ! needs-restarting -r >/dev/null 2>&1; then
      echo "=========================================================="
      echo " [NOTICE] Core libraries or kernel updated. Reboot recommended."
      echo "=========================================================="
    fi
  fi
}

# -----------------------------------------------------------------------------
# Arch Linux Support
# -----------------------------------------------------------------------------

pacman_clear_cache () {
  echo "Clearing pacman cache..."
  if [ -x /usr/bin/paccache ]; then 
    paccache -rk1
  else
    yes Y | sudo pacman -Scc
  fi
  touch_marker "${CLEARED_CACHE_MARKER}"
}

update_mirrorlist () {
  if ! command_exists reflector; then
    echo "reflector command not found; skipping mirrorlist update" >&2
    return 0
  fi
  set -x
  local country_args=()
  if [ -n "${REFLECTOR_COUNTRY}" ]; then
    country_args=(--country "${REFLECTOR_COUNTRY}")
  fi
  sudo reflector \
      --threads 8 \
      --delay 1 \
      "${country_args[@]}" \
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

replace_mirrorlist () {
  if [ -f "${MIRROR_LIST_LOCATION}" ] && ! cmp "${MIRROR_LIST_LOCATION}" "/etc/pacman.d/mirrorlist" >/dev/null 2>&1; then
    sudo cp -v "${MIRROR_LIST_LOCATION}" "/etc/pacman.d/mirrorlist"
  fi
}

use_reflector () {
  if [ ! -f "${MIRROR_LIST_LOCATION}" ]; then
    echo 'Mirrorlist cache not found'
    echo 'Using existing one to populate cache'
    if [ -f /etc/pacman.d/mirrorlist ]; then
      cp -v /etc/pacman.d/mirrorlist "${MIRROR_LIST_LOCATION}"
    fi
  fi
  phile_czekr "${MIRROR_LIST_LOCATION}" "${MIRROR_UPDATE_INTERVAL}" update_mirrorlist
  replace_mirrorlist
}

update_omarchy () {
  if [ -x "${HOME}/.local/share/omarchy/bin/omarchy-update" ]; then
    omarchy-update -y
  fi
}

update_pacman () {
  if [ -f /var/cache/pacman/pkg/cache.lck ] || [ -f /var/lib/pacman/db.lck ]; then
    echo "Pacman lock file exists (/var/lib/pacman/db.lck or /var/cache/pacman/pkg/cache.lck)!" >&2
    echo "Check if another pacman process is running." >&2
    return 1
  fi
  if [ "${PACMAN_LOOPER}" = "true" ]; then
    loop_update_pacman
  else
    update_pacman_core
  fi
}

loop_update_pacman () {
  local looper=0
  local returnCode=1
  while [ "$looper" -le 10 ]; do
    sudo ls -alh "${ROOT_UPDATED_MARKER}" >/dev/null 2>&1
    returnCode=$?
    if [ $returnCode -eq 0 ]; then
      echo "# BREAK! update marker found, breaking looper at $looper loops"
      break
    else
      echo "### update marker not found, at $looper loops"
      looper=$((looper+1))
      update_pacman_core
      update_omarchy
    fi
  done
}

update_pacman_core () {
  local returnCode=1
  if [ "${USE_POWERPILL}" = "true" ]; then
    sudo pacman -Sy --noconfirm
    if [ -x /usr/bin/powerpill ]; then
      sudo powerpill -Su --noconfirm
      returnCode=$?
    else
      echo 'Error: powerpill not found!' >&2
      return 1
    fi
  else
    sudo pacman -Syu --noconfirm
    returnCode=$?
  fi
  if [ $returnCode -eq 0 ]; then
    touch_marker "${ROOT_UPDATED_MARKER}"
  else
    sudo pacman -Sy --noconfirm ${ONE_RING_TO_RULE_THEM_ALL}
  fi
  return $returnCode
}

cleanring_arch () {
  sudo killall gpg-agent || true
  set -eux
  local backup_dir="/tmp/pacman-gnupg-backup-$(date +%s)"
  sudo mv -v /etc/pacman.d/gnupg "${backup_dir}"
  sudo pacman-key --init
  sudo pacman-key --populate
  sudo pacman-key --refresh-key
  sudo systemctl restart gpg-agent@etc-pacman.d-gnupg.socket
  sudo pacman -Sy archlinux-keyring
}

pacman_update () {
  use_reflector
  phile_czekr "${CLEARED_CACHE_MARKER}" "${SYSTEM_CLEARCACHE_INTERVAL}" pacman_clear_cache
  phile_czekr "${ROOT_UPDATED_MARKER}" "${SYSTEM_UPDATE_INTERVAL}" update_pacman
}

# -----------------------------------------------------------------------------
# Debian / Ubuntu Support
# -----------------------------------------------------------------------------

check_apt_locks () {
  local locked=0
  for lock in /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/lib/dpkg/lock; do
    if sudo fuser "$lock" >/dev/null 2>&1; then
      echo "Debian package manager lock is active ($lock)!" >&2
      locked=1
    fi
  done
  if [ $locked -eq 1 ]; then
    echo "Another package manager process (e.g. unattended-upgrades) is running. Please wait or resolve it." >&2
    return 1
  fi
  return 0
}

apt_clear_cache () {
  echo "Clearing APT cache and autoremoving orphan packages..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
  sudo apt-get autoclean
  touch_marker "${CLEARED_CACHE_MARKER}"
}

update_apt_core () {
  check_apt_locks || return 1
  local ret=0
  echo "Running apt-get update..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get update
  echo "Running apt-get ${APT_UPGRADE_TYPE}..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get "${APT_UPGRADE_TYPE}" -y
  ret=$?
  if [ $ret -eq 0 ]; then
    touch_marker "${ROOT_UPDATED_MARKER}"
  fi
  return $ret
}

cleanring_debian () {
  echo "Refreshing and repairing Debian/Ubuntu archive keyrings..."
  sudo apt-get update -o Acquire::AllowInsecureRepositories=true 2>/dev/null || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get install --reinstall -y debian-archive-keyring ubuntu-keyring 2>/dev/null || \
  sudo DEBIAN_FRONTEND=noninteractive apt-get install --reinstall -y debian-archive-keyring 2>/dev/null || \
  sudo DEBIAN_FRONTEND=noninteractive apt-get install --reinstall -y ubuntu-keyring 2>/dev/null || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get update
}

update_mirrors_debian () {
  if command_exists netselect-apt; then
    echo "Using netselect-apt to test and select the fastest Debian mirror..."
    sudo netselect-apt
  else
    echo "Refreshing APT package lists..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
  fi
}

apt_update () {
  phile_czekr "${CLEARED_CACHE_MARKER}" "${SYSTEM_CLEARCACHE_INTERVAL}" apt_clear_cache
  phile_czekr "${ROOT_UPDATED_MARKER}" "${SYSTEM_UPDATE_INTERVAL}" update_apt_core
}

# -----------------------------------------------------------------------------
# Red Hat / Fedora / CentOS / Rocky / AlmaLinux Support
# -----------------------------------------------------------------------------

get_redhat_pkg_mgr () {
  if [ -n "${REDHAT_PKG_MGR:-}" ]; then
    echo "${REDHAT_PKG_MGR}"
  elif command_exists dnf; then
    echo "dnf"
  elif command_exists yum; then
    echo "yum"
  elif command_exists microdnf; then
    echo "microdnf"
  else
    echo "dnf"
  fi
}

check_redhat_locks () {
  for lock in /var/run/dnf.pid /var/cache/dnf/metadata_lock.pid /var/run/yum.pid; do
    if [ -f "$lock" ]; then
      if sudo fuser "$lock" >/dev/null 2>&1; then
        echo "Red Hat package manager lock is active ($lock)!" >&2
        return 1
      fi
    fi
  done
  return 0
}

dnf_clear_cache () {
  local mgr
  mgr=$(get_redhat_pkg_mgr)
  echo "Clearing ${mgr} cache and orphan dependencies..."
  sudo "$mgr" autoremove -y 2>/dev/null || true
  sudo "$mgr" clean all
  touch_marker "${CLEARED_CACHE_MARKER}"
}

update_dnf_core () {
  check_redhat_locks || return 1
  local mgr
  mgr=$(get_redhat_pkg_mgr)
  local ret=0
  echo "Running ${mgr} upgrade..."
  sudo "$mgr" upgrade -y
  ret=$?
  if [ $ret -eq 0 ]; then
    touch_marker "${ROOT_UPDATED_MARKER}"
  fi
  return $ret
}

cleanring_redhat () {
  echo "Reimporting RPM distribution GPG keys..."
  sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* 2>/dev/null || true
  local mgr
  mgr=$(get_redhat_pkg_mgr)
  sudo "$mgr" makecache --refresh
}

update_mirrors_redhat () {
  local mgr
  mgr=$(get_redhat_pkg_mgr)
  echo "Refreshing ${mgr} repository metadata and fastestmirror cache..."
  sudo "$mgr" makecache --refresh
}

dnf_update () {
  phile_czekr "${CLEARED_CACHE_MARKER}" "${SYSTEM_CLEARCACHE_INTERVAL}" dnf_clear_cache
  phile_czekr "${ROOT_UPDATED_MARKER}" "${SYSTEM_UPDATE_INTERVAL}" update_dnf_core
}

# -----------------------------------------------------------------------------
# openSUSE Support
# -----------------------------------------------------------------------------

update_zypper () {
  sudo zypper -n update
  touch_marker "${ROOT_UPDATED_MARKER}"
}

zypper_update () {
  phile_czekr "${ROOT_UPDATED_MARKER}" "${SYSTEM_UPDATE_INTERVAL}" update_zypper
}

# -----------------------------------------------------------------------------
# NixOS Support
# -----------------------------------------------------------------------------

update_nix () {
  if command_exists nx; then
    nx auto -f
    touch_marker "${ROOT_UPDATED_MARKER}"
  else
    echo "nx is not installed" >&2
    return 1
  fi
}

nix_update () {
  phile_czekr "${ROOT_UPDATED_MARKER}" "${SYSTEM_UPDATE_INTERVAL}" update_nix
}

# -----------------------------------------------------------------------------
# Universal Dispatchers
# -----------------------------------------------------------------------------

try_update () {
  check_hooks
  local ret=0
  if is_arch; then
    pacman_update
    ret=$?
  elif is_debian; then
    apt_update
    ret=$?
  elif is_redhat; then
    dnf_update
    ret=$?
  elif is_suse; then
    zypper_update
    ret=$?
  elif is_nixos; then
    nix_update
    ret=$?
  else
    echo "unknown os = ${NAME:-unknown} bailing out!" >&2
    ret=1
  fi

  if [ $ret -eq 0 ]; then
    check_reboot_required
    check_outhooks
  fi
  return $ret
}

cleanring () {
  if is_arch; then
    cleanring_arch
  elif is_debian; then
    cleanring_debian
  elif is_redhat; then
    cleanring_redhat
  else
    echo "cleanring is not implemented for ${NAME:-unknown}" >&2
    return 1
  fi
}

update_mirrors () {
  if is_arch; then
    use_reflector
  elif is_debian; then
    update_mirrors_debian
  elif is_redhat; then
    update_mirrors_redhat
  else
    echo "Mirror updating not implemented for ${NAME:-unknown}" >&2
  fi
}

# -----------------------------------------------------------------------------
# System Power & State
# -----------------------------------------------------------------------------

try_shutdown () {
  if [ "${1:-}" = "-n" ] || [ "${1:-}" = "--dry-run" ] || [ "${DRY_RUN:-}" = "true" ]; then
    echo "[DRY-RUN] sudo poweroff"
    return 0
  fi
  sudo poweroff
}

try_sleep () {
  systemctl suspend
}

try_reboot () {
  if [ "${1:-}" = "-n" ] || [ "${1:-}" = "--dry-run" ] || [ "${DRY_RUN:-}" = "true" ]; then
    echo "[DRY-RUN] sudo reboot"
    return 0
  fi
  sudo reboot
}

try_suspend () {
  systemctl suspend
}

try_hibernate () {
  local swapon_count
  swapon_count=$(swapon | wc -l)
  if [ "$swapon_count" -gt 1 ]; then
    systemctl hibernate
  else
    echo 'No swap found, cannot hibernate!' >&2
    return 1
  fi
}

try_hybrid () {
  systemctl hybrid-sleep
}

powertop_auto_tune () {
  if command_exists powertop; then
    sudo powertop --auto-tune
  fi
}

get_cpu_freq_limits () {
  local max_file=""
  local min_file=""
  for policy in /sys/devices/system/cpu/cpufreq/policy* /sys/devices/system/cpu/cpu*/cpufreq; do
    if [ -f "${policy}/cpuinfo_max_freq" ]; then
      max_file="${policy}/cpuinfo_max_freq"
      min_file="${policy}/cpuinfo_min_freq"
      break
    fi
  done

  if [ -z "${max_file}" ] || [ ! -f "${max_file}" ]; then
    echo "cpufreq policy not found in /sys/devices/system/cpu/." >&2
    return 1
  fi

  CPU_MAX_FREQ=$(cat "${max_file}")
  CPU_MIN_FREQ=$(cat "${min_file}")
}

cpufreqqr () {
  THIS_GOVERNOR="$1"
  THIS_MAXFREQ="$2"
  THIS_MINFREQ="$3"
  if command_exists cpupower; then
    sudo cpupower frequency-set --min "${THIS_MINFREQ}" --max "${THIS_MAXFREQ}" --governor "${THIS_GOVERNOR}"
    sudo cpupower frequency-info
  elif command_exists cpufreq-set; then
    CPU_COUNT=$(lscpu -p | grep -E -v '^#' | sort -u -t, -k 2,4 | wc -l)
    count_zero=0
    while [ "${count_zero}" -lt "${CPU_COUNT}" ]; do
      sudo cpufreq-set -c "${count_zero}" -g "${THIS_GOVERNOR}" --max "${THIS_MAXFREQ}" --min "${THIS_MINFREQ}"
      count_zero=$((count_zero+1))
    done
    cpufreq-info
  else
    echo "Neither cpupower nor cpufreq-set was found on this system." >&2
    return 1
  fi
}
