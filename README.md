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
* **`MorningUpdate`**: Unceremoniously clears marker and updates the system packages.
* **`UpdateOnly`**: Updates the system packages if the update interval has elapsed.
* **`UUUpdateAndShutdown`**: Updates the system if needed, and safely powers off only if the update succeeded.
* **`FFForceUpdateAndShutdown`**: Forces an update (clearing the timestamp placeholder) and then shuts down if successful.
* **`mmmirrorUpdater`**: Refreshes and sorts mirrors using reflector.
* **`ArchLinuxCleanRing`**: Reinitializes pacman keyring in case of GPG verification issues.

### CPU & Power Management
* **`Low`**: Scales CPU down to ~25% max frequency under `powersave` governor.
* **`Mid`**: Scales CPU down to ~50% max frequency under `powersave` governor.
* **`Performance`**: Scales CPU to maximum frequency under `performance` governor.
* **`PowerSave`**: Scales CPU to minimum frequency under `powersave` governor and runs `powertop --auto-tune`.

## Ceremony

`Ceremony` checks if the machine has been updated within the configured interval (default: 1 day). If updated recently, the package manager step is skipped; otherwise, it runs.

## Supported Distributions

* **Arch Linux / Omarchy / EndeavourOS / Manjaro** (`pacman` / `powerpill` / `reflector`)
* **Debian / Ubuntu / Linux Mint** (`apt-get`)
* **Fedora / RHEL / CentOS** (`dnf`)
* **openSUSE / Tumbleweed / Leap** (`zypper`)
* **NixOS** (`nx`)

## Configuration

The following environment variables can be set to customize behavior:

* `SYSTEM_UPDATE_INTERVAL`: Interval in days between package updates (default: `1`).
* `MIRROR_UPDATE_INTERVAL`: Interval in days between reflector mirrorlist refreshes (default: `7`).
* `SYSTEM_CLEARCACHE_INTERVAL`: Interval in days between cache cleanings (default: `30`).
* `REFLECTOR_COUNTRY`: Country code for reflector (default: `US`).
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
