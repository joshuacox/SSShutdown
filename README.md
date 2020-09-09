# SSShutdown

Abstract shutdown, reboot, and updating and shutdown, this is to get into good habits of never using poweroff or reboot in the terminal, as these commands will not be present on a remote machine you will presented with a command not found error when you type UUUpdateAndShutdown on a remote host

## Commands

### RRReboot

unceremoniously reboots the machine

### SSShutdown

unceremoniously shuts down the machine

### UpdateAndShutdown

ceremoniously updates the machine and then shuts down the machine

### UpdateOnly

ceremoniously updates the machine

### Ceremony

`ceremony` is to be defined here as checking if the machine has been updated in the past day, if so skip the update, if not do the update.  

## Installation

If you have permissions to install files in `/usr/local` you can merely:

`make install`

Otherwise you might use sudo:

`sudo make install`

Or place it elsewhere:

`PREFIX=/opt make -e install`

Notice the use of the `-e` flag to get make to let environment variables pass thru.

### oneliner

Trust me?

```
curl -sL https://git.io/ssshutdown | bash
```
