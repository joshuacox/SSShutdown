# SSShutdown

Abstract shutdown, reboot, and updating and shutdown, this is to get into good habits of never using poweroff or reboot in the terminal, as these commands will not be present on a remote machine you will presented with a command not found error when you type UUUpdateAndShutdown on a remote host

### RRReboot

unceremoniously reboots the machine

### SSShutdown

unceremoniously shuts down the machine

### UpdateAndShutdown

ceremoniously updates the machine and then shuts down the machine

### UpdateOnly

ceremoniously updates the machine and then shuts down the machine

### Ceremony

`ceremony` is to be defined here as checking if the machine has been updated in the past day, if so skip the update, if not do the update.  
