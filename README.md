# 42Porto_Born2beRoot
Create and configure Virtual Machine following specific rules, add a shell script for monitoring the system.
## Index

- [VirtualBox](#virtualbox)
- [VM (Virtual Machine)](#vm-virtual-machine)
- [LVM (Logical Volume Manager)](#lvm-logical-volume-manager)
- [VM configuration](#vm-configuration)
  - [sudo / su](#sudo--su)
  - [Users, Groups and Hostname](#users-groups-and-hostname)
  - [Install Vim, Git (optional) and AppArmor](#install-vim-git-optional-and-apparmor)
  - [SSH - install and config](#ssh---install-and-config)
  - [Run VM remotely through SSH port](#run-vm-remotely-through-ssh-port)
  - [Firewall - install and config](#firewall---install-and-config)
  - [Close DHCP Port](#close-dhcp-port)
  - [Strong password config for sudo](#strong-password-config-for-sudo)
  - [Password Policy](#password-policy)
- [Script](#script)
  - [Monitoring](#monitoring)
- [Cron](#cron)
  - [Sync date and time](#sync-date-and-time)
- [Install Wordpress (+lighttp, MariaDB, PHP)](#install-wordpress-lighttp-mariadb-php)
- [Signature](#signature)
- [Useful links](#useful-links)


## VirtualBox

For installation and partitioning you can follow [gemartin99](https://github.com/gemartin99/Born2beroot-Tutorial/tree/main) guide. Just take care to convert GB to GiB when determining partition size. 

VirtualBox software allows guest operating system to run on another operating system. 

Do not allocate more than 50% of memory (or CPU count for processor memory) of your host system, to avoid crashing it. Video memory - as much as possible. 

An ISO file (often called an **ISO image**), is an archive file that contains an identical copy (or image) of data found on an optical disc, like a CD or DVD.

Put the image in **sgoinfre** (/nfs/homes/your_username/sgoinfre) if you are installing at school. It does not have artificial limits, so we will have enough space to install.

**Snapshot:** save a particular state of a virtual machine and revert back to that state.

## VM (Virtual Machine)

VM is a software emulation of a physical computer system. It allows you to run multiple operating systems simultaneously on a single physical machine, each in its isolated virtual environment.
Normally, a VM is shown as a window on your computer’s desktop, but it can be full-screen or run on a remote computer.

## LVM (Logical Volume Manager)

LVM is a software-based approach to manage storage devices and logical volumes in Linux operating systems. Allows the creation of ‘groups’ of disks or partitions that can be assembled into a single (or multiple) filesystem.

Partitioning bonus: gigabytes to gibibytes converter (e.g. 500MiB = 524.288MB). Convert when creating partitions.

If partitions are already created, resize with the following command (XXX is the size to increment in mb) and (YYY the corresponding partition) `sudo lvresize -L +XXXm /dev/LVMGroup/YYY`

Resize the boot partition. Install parted: `sudo apt install parted`. 

Resize the partition:`sudo parted /dev/sda resizepart 1 XXXM` (value in MB)

Resize the filesystem to make it aware of the new partition size: `sudo resize2fs /dev/sda1`

Check the partitions in terminal: `lsblk`

## VM configuration

### sudo / su

`su` command stands for *substitute user* or *superuser.* `su` requires the password of the target account, you gain root privileges.

`sudo` is used as a prefix to [Linux commands](https://phoenixnap.com/kb/linux-commands), which allows the logged in user to execute commands that require root privileges.`sudo` requires the password of the current user. `sudo` option can only be used by users who belong to the sudoers group.

it is advisable to stick to `sudo` when performing tasks that require root privileges. By doing so, the 
current user is only privileged for the specified command. On the other hand, `su` switches to the root user completely, exposing the entire system to potential accidental modification.

→ Write `su -`  and insert root password ( `-` fully initializes the environment of the user). 

`apt update` and `apt upgrade` (do every time before installing new software).

`apt install sudo` to install necessary packages.

`sudo reboot` - restart the VM.

`sudo -V` : check the sudo version and configuration parameters.

### Users, Groups and Hostname

Change hostname: `sudo hostnamectl set-hostname <new_hostname>.`

Check who is host: `hostnamectl status` / `hostname`.

`sudo adduser <username>`.

`sudo addgroup user42` - create new group called “user42”. GID - Group Identifier.

`sudo adduser <username> <groupname>` add user to a specific group (last two being placeholders).

`getent group <groupname>`  : displays a list of all users in a group/check if the group was created.

`cat /etc/group` - see all groups and their users.

`groups <username>` : displays the groups of a user.

`users`: see users who are currently logged-in.

`getent passwd`: list of all users on the system, including regular user accounts, system accounts, and service accounts.

`userdel -r <username>`: remove user and his home directory.

`id -u` : displays user ID.

`id -g` : shows a user’s main group ID.

Change password: enter the user and type `passwd` in terminal.

switch from root to user: `su - <username>`

**Adding a User to the Sudoers Group:**

For a user to execute a command that requires the `sudo` prefix, it has to be part of the **sudoers** group.

To add a user to the **sudoers** group, run the following command (as root or an account that already has sudo privileges): `usermod -aG sudo <username>`(-a for append; -G for supplementary groups; -g for primary groups). Use this command to add user to any other group, if the user has been already created.

To see a list of accounts that belong to the sudoers group run: `sudo getent group sudo`

### Install Vim, Git (optional) and AppArmor

Git: `sudo apt-get install git -y`. 

Check the version: `git --version`.

Vim: `sudo apt install vim`**.**

Check the version: `vim --version`**.** 

*AppArmor* is a security feature to protect your computer by restricting the actions that individual applications or processes can take. It acts like a protective shield around each application, ensuring that it can only access approved resources and perform allowed actions. AppArmor works by creating a set of rules or policies that define the permissions for each application. These policies specify which files, directories, network resources, and other system functions an application is allowed to access. AppArmor comes with Debian by default, but you can also install it if needed.

Install AppArmor: `sudo apt install apparmor apparmor-profiles apparmor-utils`.

Check status: `sudo apparmor_status.` Check if running: `systemctl status apparmor`.

### SSH - install and config

SSH (Secure Shell) is a network protocol that gives users, particularly system administrators, a secure way to access a computer over an unsecured network. Allows two computers to communitate and share data, encrypts all traffic. Its most notable applications are remote login and command-line execution.

First `sudo apt update`

Install OpenSSH: `sudo apt install openssh-server`

Verify ssh service: `sudo service ssh status` and the status should be active.

Configure the files `/etc/ssh/sshd_config` (use nano, vim (`sudo apt install vim`)), you have to be root. `nano /etc/ssh/sshd_config`.

Remove `#` from lines you want to modify. 

#Port 22 -> Port 4242

#PermitRootLogin prohibit-password -> `PermitRootLogin no`. Important to exclude root to reduce hack damage!

Now modify file `/etc/ssh/ssh_config`.

#Port 22 -> Port 4242 (remove spaces from front)

Restart the ssh service to update the changes `sudo service ssh restart`.

Check if the changes have been made `sudo service ssh status`.

### Run VM remotely through SSH port

Close VM and in VirtualBox Manager go to Settings → Netfwork → Change Attached to: Bridged Adapter.

**NAT** (Network Address Translation): VM shares the host system's IP address for outgoing connections. NAT is useful when you want your virtual machine to have internet access but don't need direct network visibility or communication with other devices on the local network.

**Bridged Network**: VM gets its own unique IP address on the same network as the host system. Bridged networking is suitable when you want your virtual machine to be seen as a separate device on the network and need it to have direct network communication with other devices.

Reboot the machine:  `sudo reboot`.

To see the ip address `ip a` through VM terminal.

Enter your terminal `ssh username@ipaddress -p 4242`.

If get any error in the connection `rm ~/.ssh/known_hosts`.

Check if the machines are connected `wall randomtext`.

### Firewall - install and config

UFW (Uncomplicated Firewall). A firewall is a security measure that controls incoming and outgoing network traffic to and from your computer. It acts as a barrier/security guard, allowing or blocking connections based on predefined rules. 

UFW provides a command-line tool that allows you to enable or disable firewall rules, define specific rules for different types of network traffic, and monitor the status of the firewall. Using UFW, you can specify which network ports should be open or closed on your computer.

Install `sudo apt install ufw`.

Activate `sudo ufw enable`.

Allow connections through port 4242 `sudo ufw allow 4242`.

Check if the changes are in place `sudo ufw status`.

### **Close DHCP Port**

If we use the `sudo ss -tunlp` command we will find that it's open to port 68, which is referring to DHCP (Dynamic Host Configuration Protocol). To close this door, we need to change the machine IP address from dynamic to static.

With or without DHCP, one must assign IP addresses to devices because they contain the information used to accurately direct the transmission of data packets passed across any network. Without DHCP, computers moved to another network will have to undergo manual configuration to assign them new IP addresses. Similarly, the IP addresses assigned to computers that have left the network must be manually retrieved.

`sudo ss -tunlp` - check the open doors  
`ip a` - get your current IP address  
`sudo nano /etc/network/interfaces`  
change line `allow-hotplug enp0s3` to `auto enp0s3`  
change line `iface enp0s3 inet dhcp` to `iface enp0s3 inet static`  
Add the following lines  
`address your_current_ip`    
`netmask 255.255.0.0`    
`gateway 10.11.254.254`  
`dns-nameservers 10.11.254.254` and exit the file  

`sudo systemctl restart networking`  
`sudo systemctl status networking`  
`sudo reboot`  
`ss -tulnp`  

### Strong password config for sudo

https://www.linux.com/training-tutorials/linux-101-introduction-sudo/

`man sudo`

If you mis-configure your /etc/sudoers file, you can damage your installation (at which point you will have to log boot in rescue mode). Sudo is VERY particular about syntax in the configuration file. Add local content in /etc/sudoers.d to avoid this issue. Else edit sudoers file with `sudo visudo`.

Create a file to store config in /etc/sudoers.d/ `touch /etc/sudoers.d/sudo_config`.

Create folder sudo in /var/log to store all commands executed by sudo `mkdir /var/log/sudo`.

Edit the sudo_config file `nano /etc/sudoers.d/sudo_config`. Write inside:

```bash
Defaults  env_reset
Defaults  passwd_tries=3
Defaults  badpass_message="Knock knock...it's error"
Defaults  logfile="/var/log/sudo/sudo_log"
Defaults  log_input, log_output
Defaults  iolog_dir="/var/log/sudo"
Defaults  requiretty
Defaults  secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

env_reset - sudo will reset the environment to a standardized default state, providing a clean and controlled environment for the executed command.

logfile - folder where all the sudo related messages will be recorded: authentication attempts, executed commands etc. 

iolog_dir - all the input and output file (previous line) will be stored in this folder.

requiretty - activate TTY (teletypewriter) mode. It provides the file name of the terminal that is currently connected to the standard input. When `requiretty` is set, `sudo` must be run from a logged-in terminal session (a tty). By enabling this option, sudo ensures that the user is physically present at the terminal to enter their password and execute commands. This prevents `sudo` from being used from daemons or other detached processes like cronjobs or webserver plugins. It also means you can't run it directly from an `ssh` call without setting up a terminal session.

secure_path - a list of directories where sudo will search for executable files when a command is executed.

### Password Policy

Edit file `/etc/login.defs`

PASS_MAX_DAYS 99999 -> PASS_MAX_DAYS 30

PASS_MIN_DAYS 0 -> PASS_MIN_DAYS 2

To continue configuration install `sudo apt install libpam-pwquality`

Edit file `/etc/pam.d/common-password`. 

After `pam_pwquality.so retry=3` on the same line add `minlen=10 ucredit=-1 dcredit=-1 lcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root`

`minlen=10` - minimum number of password characters

`ucredit=-1` - at least one uppercase (”-”at least, “+”not more than)

`dcredit=-1` - at least one digit

`lcredit=-1` - at least one lowercase

`maxrepeat=3` - not more than 3 repeated characters in a row

`reject_username` - cannot contain username

`difok=7` - at least 7 different characters compared to previous password

`enforce_for_root` - same rules for root.

Check settings for user and for root: `chage -l <username>`. 

Update passwd policy for your user: `sudo chage --maxdays 30 --mindays 2 --warndays 7 <username>`.

## Script

Script - sequence of commands stored in a file that when executed will do the function of each command.

`Wall` -  displays a message or the contents of a file on the terminals of all currently logged in users.

`grep` - grab a pattern and return the line where this pattern is found (`-i` ignore case).

`awk` - pattern scanning and processing. Splits input lines into fields and compares line/field to pattern.

`wc` - prints a newline (-l), word (-w), chars (-m) and byte (-c) counts for files.

- **Architecture**: command `uname -a` (”a” stands for “all”).
- How many **physical processors**: use the file /proc/cpuinfo, `cat /proc/cpuinfo` it to see inside. `grep "physical id" /proc/cpuinfo | sort | uniq | wc -l` : sort and uniq guarantees that there are no duplicates (physical processor might be the same for each virtual).
- How many **virtual processors**: `grep "^processor" /proc/cpuinfo | wc -l`. ^ indicates beginning of the line = “line starting with the word processor..” Duplicates should not appear, so no need for the rule.
- **RAM memory** available in MB and usage in %. Subject text dosn´t match subject example (one states available memory and the other one - used). I will follow the example with used memory display as it makes more sense to me. Command `free --mega` to see info about RAM. Current available RAM and its utilization rate as a percentage: divide used by total and display the result as percentage (multiply by 100 and add % sign). Get used memory: `free --mega | grep Mem | awk '{print $3}'` (get row containing Mem, and print 3rd column). Get total memory: `free --mega | grep Mem | awk '{print $2}'`. Display percentage: `free --mega | grep Mem | awk '{printf("%.2f"), $3/$2*100}'`.
- **Server (disk) memory** available in GB and usage in %. Command `df` stands for "disk filesystem”, it will show the disk space. To show it in MB use the flag `-m` and in GB use 2 flags: `-B` to show the block size of the size we will ask, and `-g` that makes the size in GB. Our server is the lines that start with `/dev/` so to get oly those lines we can `grep "^/dev/"`. Exclude lines that end with “boot” because we don’t have access to it: `grep -v "/boot$”`. Create variable “disk_used” and use the awk command and sum the value of the 4th word of each line and once all the lines are summed, print the final result of the sum: `awk '{disk_used += $3} END {print disk_used}'`. Used disk memory: `df -Bm | grep "^/dev/" | grep -v "/boot$" | awk '{disk_used += $3} END {print disk_used}'`. Total disk memory: `df -Bg | grep "^/dev/" | grep -v "/boot$" | awk '{disk_total += $2} END {print disk_total}'`. Calculate percentage used_space / total_space * 100: `df -m | grep "^/dev/" | grep -v "/boot$" | awk '{disk_used += $3} {disk_total+= $2} END {printf("%.2f"), disk_used/disk_total*100}'`.
- **Processors (CPU) usage percentage**. Command `top` already give us the CPU %. `top -bn1 | grep "^%Cpu" | awk '{printf("%.1f"), 100-$8}'` . Flag `-b` to start in batch mode: useful for sending output from top to other programs or to a file; Flag `-n` that specify the max number of iterations or frames. `grep "^%Cpu"` get the line that contains CPU %. `awk '{printf("%.1"), 100-$8}'` print the value minus idle time CPU which is field 8.
- **Date and time of the last reboot**. Command `who` with the `-b` flag, as this flag will display the time of the last system boot. `who -b | grep system | awk '{print $3 " " $4}'`.
- **LVM active or not**. Command `lsblk` shows information about all block devices (hard drives, SSDs, memories, etc). If condition: count the number of lines in which "lvm" appears and if there are more than 0 print Yes, if there are 0 print No.

```bash
if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; #gt - greater than, eq - equal to
then echo yes; 
else echo no;
fi
```

- Number of **active TCP** (Transmission Control Protocol) connections. A TCP connection represents a logical channel or session established between two devices, typically a client and a server, to facilitate the exchange of data. It provides reliable, connection-oriented communication, ensuring that data is delivered accurately and in the correct order. `netstat` command is not used anymore, take `ss` (socket statistics) instead. `-a` (all) flag not necessary, since we don’t look for non-established sockets. `-t` displays TCP sockets. `ss -t | grep ESTAB | wc -l`
- Number the **users** using the network. `users | wc -w`
- **IPv4 address** of your server and its **MAC** (Media Access Control) address. IP address: `hostname -i` (-i displays only the hosts IP / network address; -I displays all computers network IP addresses). Normally it’s in IPv4 format. If in trouble `ifconfig -4` gets only IPv4. MAC: `ip link show | grep ether | awk '{print $2}'` or `ifconfig -a | grep ether | awk '{print $2}'`(latter is deprecated) .
- Number of **commands executed with the sudo program**. Command `journaclctl` is a tool for collecting and managing the system logs. If you don’t have access to this command `sudo apt install net-tools`. `_COMM=sudo` filters the entries where the command name is “sudo”. When you start or close the root session it also appears in the log, so to finish filtering we will put a `grep COMMAND` and this will only show the command lines. `journalctl _COMM=sudo | grep COMMAND | wc -l`

### Monitoring

You can find the script monitoring.sh in the root of this repository. 

Open the folder where the script will be placed: `cd /usr/local/bin`(used for locally installed binaries that are not part of the core operating system).

Create monitoring.sh in this folder (nano, vim, touch..).

Give permissions to read and execute `chmod +rx monitoring.sh`.

Add the rule to execute the script without the sudo password. `sudo visudo`

Under `%sudo ALL=(ALL:ALL) ALL` add this line to run the script without password `your_username ALL=(ALL) NOPASSWD: /usr/local/bin/monitoring.sh` (although since the script will run from root crontab and will use wall, it will execute also without this line, but it’s handy to know that we can grant access to execute commands without password).

`sudo reboot`

## Cron

Cron is a time-based job scheduler. It allows users to schedule and automate the execution of tasks or commands at predefined intervals or specific times. Daemon - computer program that runs as a background process, rather than being under the direct control of an interactive user.The crontab file follows a specific format with fields representing / minutes / hours / days of the month / months / and days of the week (0 and 7 are Sunday)/ followed by the command to be executed. Each field can contain a value or a wildcard (*) to match any value. For example, a line in a crontab file might look like: `30 8 * * * /path/to/command`**.**

System-wide crontab files are typically located in the `/etc` directory and are used for tasks that should run regardless of the user logged in. User-specific crontab files can be managed with the `crontab` command and are located in each user's home directory.

To edit crontab file: `sudo crontab -u root -e` (-user, -edit). `*/10 * * * * /usr/local/bin/monitoring.sh` will run the script every 10 minutes `/` stands for step. But it will run on fixed minutes, e.g., 15:00, 15:10 etc. To take into account the boot time we need to add a delay that is the same amount that the second digit of minutes that we started the system: `sleep $(who -b | awk '{split($4, time, ":"); print time[2]%10}')m` split the 4th field by delimiter “:” and print %10 of the 2nd field. Create a file with this script in the same folder as monitoring.sh `/usr/local/bin/sleep_mon.sh`, add +rx permissions and add the path to sleep delay. The full line: `*/10 * * * * /usr/local/bin/sleep_mon.sh; /usr/local/bin/monitoring.sh`. 

To make the script run after reboot add `@reboot /usr/local/bin/monitoring.sh` under the 10 min line. Add the sleep for 10 seconds to allow other system services and processes to initialize properly before executing the script. `@reboot sleep 10; /usr/local/bin/monitoring.sh`. 

To check scheduled cronjobs: `sudo crontab -u root -l`.

### Sync date and time

If after saving VM in Current State it will boot with the same date and time when it was logged off previously (fails to update time), install and config NTP (Network Time Protocol) to sync your date: `sudo apt install ntp`. 

Edit NTP config file: `sudo nano /etc/ntp.conf`.

Find lines that start with “server” and add several servers (will depend on your country). For Portugal, add these lines:

```bash
server pt.pool.ntp.org
server ntp02.fccn.pt
server ntp04.fccn.pt
```

`sudo systemctl restart ntp`.

Check if your time is updated: `date`.

## Install Wordpress (+lighttp, MariaDB, PHP)

You can follow installation and configuration from [gemartin99](https://github.com/gemartin99/Born2beroot-Tutorial/blob/main/README_EN.md#82---wordpress--services-configuration-).

*Lighttpd* is open-source web server software. It's designed specifically for environments with limited resources since it consumes minimal CPU and RAM.

*MariaDB*: open source database solution. 

*PHP*: general-purpose scripting language that is especially suited for web development.

Some of my comments:

Add new port connection: `sudo ufw allow 80`. Port 80 is default port for HTTP traffic. For future fererence port 443 is the default port for HTTPS traffic.

Check UFW status: `sudo ufw status`. 

Download latest version of Wordpress: `sudo wget https://wordpress.org/latest.zip`*.*

Set permissions for html folder: `sudo chmod -R 777 html` (e.g., to be able to ulpoad files to wp).

Check if MariaDB is working: `systemctl status mariadb`.

Check if PHP is working with lighttpd, create a file in `/var/www/html` named `info.php`. In that php file, write:

```bash
<?php
phpinfo();
?>
```

Then in your browser enter `<IP.address>/info.php` and a page with PHP info should appear.

Extra service *Fail2Ban*: security tool that protects your server from brute-force attacks by monitoring log files and blocking IP addresses that show suspicious activity.

You can follow [this guide of  mcombeau](https://github.com/mcombeau/Born2beroot/blob/main/guide/bonus_debian.md) to install and configure.

Check if installed and working: `sudo systemctl status fail2ban.` Check status: `sudo fail2ban-client status`.

To see banned IP addresses for SSH: `sudo fail2ban-client status sshd`. 

## Signature

Turn off VM: `sudo shutdown now`.

Open terminal and cd into the path where is the .vdi of virtual machine. `sha1sum <VM_name>.vdi`

It will display a line that is the ID of our VM. Copy it into signature.txt.

It is important not to reopen the VM from this point on, because that will change the signature number. Take a snapshot or clone the machine for evaluation.

## Useful links

VirtualBox manual: http://download.virtualbox.org/virtualbox/UserManual.pdf

Guide to VirtualBox: https://www.saashub.com/videos/sB_5fqiysi4/modal

Guide and evaluation questions (outdated version): https://github.com/benmaia/42_Born2beRoot_Guide/tree/master

Linux Directories Explained in 3mins: https://www.youtube.com/watch?v=42iQKuQodW4

Sudo crash course: https://www.youtube.com/watch?v=07JOqKOBRnU

AWK: https://www.geeksforgeeks.org/awk-command-unixlinux-examples/
