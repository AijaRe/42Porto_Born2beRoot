# Born2beRoot evaluation
You can find evaluation questions [here in rphlr repo](https://github.com/rphlr/42-Evals/tree/main/Rank01/Born2beroot).
This is additional information to the configuration guide.
# Index

- [Project overview](#project-overview)
  - [How a VM works? The purpose of VM.](#how-a-vm-works-the-purpose-of-vm)
  - [Difference between Rocky and Debian? Why Debian?](#difference-between-rocky-and-debian-why-debian)
  - [Difference between aptitude and apt?](#difference-between-aptitude-and-apt)
  - [What is AppArmor?](#what-is-apparmor)
- [Simple setup](#simple-setup)
- [User](#user)
- [Hostname and partitions](#hostname-and-partitions)
- [Sudo](#sudo)
- [UFW](#ufw)
- [SSH](#ssh)
- [Script monitoring](#script-monitoring)

## Project overview

### How a VM works? The purpose of VM.

A virtual machine (VM) is like a computer within a computer. It allows you to create virtual computers within a physical machine, enabling you to run multiple operating systems or applications independently and securely in a special environment, on top of your existing operating system. 

This environment, called a "virtual machine", is created by the virtualization software by intercepting access to certain hardware components and certain features. A special software called a hypervisor creates a virtual environment that simulates the hardware of a computer, including a virtual CPU, memory, storage, and network interfaces. This virtual hardware is not physically present but appears to be real to the operating system running on the VM. This isolation is crucial for security and stability.

The physical computer is then usually called the "host", while the virtual machine is often called a "guest". Most of the guest code runs unmodified, directly on the host computer, and the guest operating system "thinks" it's running on real machine.

Main benefits: 

- Multiple VMs can run on a single physical server, reducing hardware costs and maximizing resource utilization.
- Developers can create VMs to test their software on different operating systems and configurations without the need for separate physical machines.

### Difference between Rocky and Debian? Why Debian?

Both are open-source OS, popular and reliable.

Rocky Linux primarily targets enterprise and server environments, aiming to provide a stable and reliable platform for production systems. More complex to use. To update version you have to remove the previous and install the new one. As a relatively new project, Rocky Linux has a growing community compared to the long-established Debian community. While Rocky Linux can be used as a general-purpose operating system, its primary focus is on server environments. It may have fewer pre-packaged software options or customizations available for desktop or non-server use cases compared to Debian.

Debian targets broad range of users, including desktop users, system administrators, and developers. It offers flexibility and customization options. Comes with many software packages to install. Easy to update. Debian's primary focus is on stability and security rather than being at the forefront of adopting the latest technologies. This can lead to a slower adoption of cutting-edge software or hardware support compared to other distributions.

### Difference between aptitude and apt?

Apt and Aptitude are both package management tools used in Debian-based Linux distributions

Apt (Advanced Packaging Tool) is a collection of tools used to install, update, remove and manage software packages. Apt offers a command-line interface, while aptitude offers a visual interface. Apt-get is the classic interface, apt is the newer UI with the same functionality.

Aptitude is more advanced, has GUI (graphic user interface). Aptitude resolves package dependencies and conflicts: apt will not fix the issue while aptitude will suggest a solution. 

### What is AppArmor?

AppArmor is like a virtual bodyguard that keeps an eye on the programs running on a computer and makes sure they stay within their designated boundaries, preventing them from causing harm to the system or accessing sensitive resources without permission. It does this by defining specific rules and permissions for each program/app, controlling what it can and cannot do. (more in the main Born2beRoot page).

## Simple setup

Ensure there is no graphical environment: `systemctl status display-manager.service`

Check if UFW is active: `sudo ufw status`

Check if SSH is active: `sudo systemctl status ssh` / `sudo service ssh status`

Check the OS: `cat /etc/os-release`

## User

Check that the user belongs to “sudo” and “user42” groups: `groups <username>` / `getent group <groupname>`

Create a new user and assign a password: `sudo adduser <username>`

Explain how the password was created: Install password quality checking library: *libpam-pwquality*. And configure with restrictions. Also add 3 attempt restriction in sudoers file for sudo password and modify expiration in login.defs file.

See password expiration: `nano /etc/login.defs`

See password policy: `nano /etc/pam.d/common-password`

Create a new group “evaluating”: `sudo addgroup evaluating`

Assign the new user to this group: `sudo adduser <username> evaluating`

Check that the user belongs to group: `getent group evaluating` / `groups <username>`

Check password policy: `sudo chage -l username`

Explain advantages and disatvantages of this password policy. Complex passwords make it more difficult for attackers to guess or crack them, reducing the risk of unauthorized access to sensitive information. Disadvantages: user frustration and paradoxically, strict password policies may drive users to adopt risky behaviors, such as writing down passwords or storing them in unsecured digital formats, which can compromise security.

## Hostname and partitions

Check the hostname: `hostname`

Modify the hostname and restart the machine: `sudo hostnamectl set-hostname <new_hostname>`. OR:

1. add user to sudogroup `usermod -aG sudo <username>` 
2. Log into user environment: `su - <username>`
3. Change the hostname: `sudo nano /etc/hostname`

Restart the machine: `sudo reboot`

Restore machine to the original hostname (rename again).

View the partitions: `lsblk`

Explain *LVM (Logical Volume Manager)* is a software tool used in computer systems to manage storage space efficiently. LVM allows you to create virtual partitions called logical volumes, which can span across multiple physical hard drives or partitions. This flexibility gives several benefits. First, you can easily resize your logical volumes without having to repartition your hard drives. Second, LVM provides a feature called snapshots. Snapshots allow you to create a read-only copy of a logical volume at a particular point in time. Another advantage of LVM is the ability to create volume groups. A volume group is a collection of physical hard drives or partitions that are managed together as a single storage pool. This pooling allows you to allocate and manage storage space more efficiently, regardless of the physical location of the data.

## Sudo

Check that sudo is properly installed: `sudo -V` / `dpkg -l | grep sudo`

Assign the new user to “sudo” group: `usermod -aG sudo <username>`

Value and operation of sudo with examples. 

Sudo stands for SuperUser DO and is used to access restricted files and operations. By default, Linux restricts access to certain parts of the system preventing sensitive files from being compromised.

The sudo command temporarily elevates privileges allowing users to complete sensitive tasks without logging in as the root user. Without sudo, regular users do not have the necessary permissions to install software in most cases.

You shouldn’t log in as root, the access rights are unlimited, this account is the most valuable target for hackers. Also you prevent rushed or accidental command executions, because when you execute sudo it requires password, but in root account an accidental enter can damage the system.

Show implementation of rules imposed by subject: `nano /etc/sudoers.d/sudo_config`

Verify /var/log/sudo/ and check that it has at least one file. 

`sudo ls /var/log/sudo/` 

Run sudo command and check if the file is updated: `sudo cat /var/log/sudo/sudo_log`. Run any sudo command and cat the file again.

## UFW

What it is and what is its value? It is a user-friendly command-line tool used for managing firewall rules in Linux-based operating systems. Protects the system from unauthorized network access by limiting the incoming traffic.

Check that UFW is installed: `dpkg -l | grep ufw`

Check that it is working properly: `sudo ufw status`

List active UFW rules: `sudo ufw status numbered`

Add new rule to open port 8080: `sudo ufw allow 8080`

Delete the new rule: `sudo ufw status numbered` -> `sudo ufw delete <rule_number>`

## SSH

Check SSH is installed: `dpkg -l | grep openssh-server`

Check it is working properly: `sudo service ssh status`

Verify that SSH uses only port 4242: `sudo service ssh status | grep listening`

Log in SSH as newly created user, using password or key. `ssh <username>@<ipaddress> -p 4242`. Access any file or broadcast a message: `sudo -E wall <Message>`

Verify that you cannot use SSH as root. Try to login as root: `ssh root@<ipaddress> -p 4242`

## Script monitoring

Explain the script.

What is Cron.

Run the script every minute: `sudo crontab -u root -e`. Change “10” to “1” and delete the sleep path. `*/1 * * * * /usr/local/bin/monitoring.sh`

Stop the script without modifying it: comment or delete the crontab lines.
