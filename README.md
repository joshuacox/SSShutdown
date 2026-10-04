# SSShutdown

Abstract shutdown, reboot, updating, and power management scripts. Getting into the habit of using these commands prevents accidental execution of bare `poweroff` or `reboot` when logged into remote systems.

## Commands

### System State
* **`RRReboot`**: Reboots the machine.
* **`SSShutdown`**: Shuts down the machine.
* **`sssuspend`**: Suspends the machine (`systemctl suspend`).
* **`hhhibernate`**: Hibernates the machine (`systemctl hibernate`, requires swap).
* **`hybrid`**: Hybrid sleep (`systemctl hybrid-sleep`).

### System Updates
* **`MorningUpdate`**: Clears update timestamp markers and forces a complete system package upgrade.
* **`UpdateOnly`**: Updates system packages only if the ceremonial update interval has elapsed.
* **`UUUpdateAndShutdown`**: Updates system packages if due, and safely powers down only if the update succeeds.
* **`FFForceUpdateAndShutdown`**: Forces an immediate upgrade and powers down on completion.
* **`mmmirrorUpdater`**: Refreshes and ranks fastest package mirrors (`reflector` on Arch, `netselect-apt` on Debian, fastestmirror on Red Hat).
* **`CleanRing`**: Universal keyring repair tool for Arch (pacman-key), Debian/Ubuntu (archive keyrings), and Red Hat (RPM GPG keys).
* **`ArchLinuxCleanRing`**: Backward-compatible alias for `CleanRing`.

### CPU & Power Management
* **`Low`**: Scales CPU down to ~25% max frequency under `powersave` governor.
* **`Mid`**: Scales CPU down to ~50% max frequency under `powersave` governor.
* **`Performance`**: Scales CPU to maximum frequency under `performance` governor.
* **`PowerSave`**: Scales CPU to minimum frequency under `powersave` governor and runs `powertop --auto-tune`.

## Ceremony

`Ceremony` checks if the machine has been updated within the configured interval (default: 1 day). If updated recently, the package manager step is skipped; otherwise, it runs. Marker timestamps are tracked per distribution in `/var/cache/` and `/root/.updated`.

## Supported Distributions

* **Arch Linux / Omarchy / EndeavourOS / Manjaro** (`pacman` / `powerpill` / `reflector`)
  - Automatic `paccache -rk1` cache management.
  - Multi-threaded reflector ranking.
* **Debian / Ubuntu / Linux Mint / Pop!_OS** (`apt-get`)
  - Non-interactive safe upgrades (`DEBIAN_FRONTEND=noninteractive`).
  - Active lock detection (`/var/lib/dpkg/lock-frontend`, unattended-upgrades).
  - Periodic `autoremove -y` and `autoclean` cache pruning.
  - Automatic reboot required detection (`/var/run/reboot-required`).
* **Red Hat / Fedora / CentOS / Rocky / AlmaLinux / Amazon Linux** (`dnf` / `yum` / `microdnf`)
  - Automated package manager lock detection.
  - Automated dependency pruning (`autoremove` and cache cleaning).
  - Reboot detection via `needs-restarting -r`.
* **openSUSE / Tumbleweed / Leap** (`zypper`)
* **NixOS** (`nx`)

## Configuration

The following environment variables can be set to customize behavior:

* `SYSTEM_UPDATE_INTERVAL`: Interval in days between package updates (default: `1`).
* `MIRROR_UPDATE_INTERVAL`: Interval in days between mirrorlist refreshes (default: `7`).
* `SYSTEM_CLEARCACHE_INTERVAL`: Interval in days between cache cleanings (default: `30`).
* `APT_UPGRADE_TYPE`: Debian upgrade type (`upgrade` or `dist-upgrade`, default: `upgrade`).
* `REDHAT_PKG_MGR`: Package manager override for Red Hat systems (`dnf`, `yum`, or `microdnf`).
* `REFLECTOR_COUNTRY`: Country code for Arch reflector (default: `US`).
* `PACMAN_LOOPER`: Retry pacman update loop on failure (default: `true`).
* `USE_POWERPILL`: Use powerpill instead of pacman (default: `false`).
* `DEBUG`: Set to `true` to enable verbose shell tracing (`set -x`).

## Installation

### Oneliner automated install

```bash
curl -sL https://raw.githubusercontent.com/joshuacox/SSShutdown/master/bootstrap | bash
```

### Makefile installation

If you have permissions to install files in `/usr/local`:

```bash
make install
```

Otherwise use sudo:

```bash
sudo make install
```

Or place it elsewhere:

```bash
PREFIX=/opt make -e install
```

### Hooks

If you need to execute custom logic before or after package manager runs, you can create hook scripts:

* Pre-hook: `/etc/ssshutdown/hooks/in`
* Post-hook: `/etc/ssshutdown/hooks/out`

To install the example templates:

```bash
sudo make hooks
```
