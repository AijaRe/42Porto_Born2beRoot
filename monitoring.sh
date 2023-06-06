#!/bin/bash

#ARCHITECTURE
arch=$(uname -a)

#PHYSICAL PROCESSORS
cpu_phys=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)

#VIRTUAL PROCESSORS
cpu_virt=$(grep "^processor" /proc/cpuinfo | wc -l)

#RAM
ram_used=$(free --mega | grep Mem | awk '{print $3}')
ram_total=$(free --mega | grep Mem | awk '{print $2}')
ram_percent=$(free --mega | grep Mem | awk '{printf("%.2f"), $3/$2*100}')

#SERVER (DISK) MEMORY
disk_used=$(df -Bm | grep "^/dev/" | grep -v "/boot$" | awk '{disk_used += $3} END {print disk_used}')
disk_total=$(df -Bg | grep "^/dev/" | grep -v "/boot$" | awk '{disk_total += $2} END {print disk_total}')
disk_percent=$(df -m | grep "^/dev/" | grep -v "/boot$" | awk '{disk_used += $3} {disk_total+= $2} END {printf("%.2f"), disk_used/disk_total*100}')

#PROCESSOR (CPU)
cpu_load=$(top -bn1 | grep "^%Cpu" | awk '{printf("%.1f"), 100-$8}')

#LAST REBOOT
last_boot=$(who -b | grep system | awk '{print $3 " " $4}')

#LVM
lvm_use=$(if [ $(lsblk | grep lvm | wc -l) -gt 0 ];
then echo yes;
else echo no;
	fi)

#TCP CONNECTIONS
tcp_active=$(ss -t | grep ESTAB | wc -l)

#USERS
users_nb=$(users | wc -w)

#IP AND MAC 
ip=$(hostname -i)
mac=$(ip link show | grep ether | awk '{print $2}')

#SUDO
sudo_commands=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

#WALL - write all :)
wall "		#Architecture : $arch
	#CPU physical : $cpu_phys 
	#vCPU : $cpu_virt
	#Memory Usage : $ram_used/${ram_total}MB ($ram_percent%) 
	#Disk Usage : $disk_used/${disk_total}Gb ($disk_percent%) 
	#CPU load : $cpu_load% 
	#Last boot : $last_boot
	#LVM use : $lvm_use
	#Connections TCP : $tcp_active ESTABLISHED
	#User log : $users_nb
	#Network : IP $ip ($mac)
	#Sudo : $sudo_commands cmd"
