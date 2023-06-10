# 42Porto_Born2beRoot
Create and configure Virtual Machine following specific rules, add a shell script for monitoring the system.

## VirtualBox

For installation and partitioning you can follow [gemartin99](https://github.com/gemartin99/Born2beroot-Tutorial/tree/main) guide (my following configuration does differ significantly) . 

VirtualBox software allows guest operating system to run on another operating system. 

Do not allocate more than 50% of memory (or CPU count for processor memory) of your host system, to avoid crashing it. Video memory - as much as possible. 

An ISO file (often called an **ISO image**), is an archive file that contains an identical copy (or image) of data found on an optical disc, like a CD or DVD.

Put the image in **sgoinfre** (/nfs/homes/your_username/sgoinfre) if you are installing at school. It does not have artificial limits, so we will have enough space to install.

Password: 42Porto2023

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

Enter your terminal `ssh username@ipaddress -p 4242`. Change to root with `su`.

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
`address your_current_ip
netmask 255.255.0.0
gateway 10.11.254.254
dns-nameservers 10.11.254.254` and exit the file

`sudo systemctl restart networking
sudo systemctl status networking
sudo reboot
ss -tulnp`

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
