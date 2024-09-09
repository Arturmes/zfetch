#!/bin/sh

#    zfetch - a fast but pretty fetch script
#    Copyright (C) 2022 - 2024 jornmann, arturmes
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# shellcheck source=/dev/null
# shellcheck disable=SC2059

# variables used: $NAME
# we do a check to see if $NAME is already set, if not, we try to detect OS
# ourselves
unset NAME
if [ "$NAME" = "" ]; then
	if [ -f /etc/os-release ]; then
		. /etc/os-release
	fi

	if [ -f /etc/prop.default ] && [ -f /bin/getprop ]; then
		NAME="Android $(getprop ro.build.version.release)"
	fi
else
	NAME=Unknown
fi

# nc = no color
nc="\033[0m"

# logos
if echo $NAME | grep -q 'Arch'; then
	dscolor="\033[0;36m" # cyan
	dslogo1="        /\         "
	dslogo2="       /  \        "
	dslogo3="      /    \       "
	dslogo4="     /  ,.  \      "
	dslogo5="    / ,'  ', \     "
	dslogo6="   /.'      '.\    "
	dslogo7="                   "
elif echo $NAME | grep -q 'Artix'; then
	dscolor="\033[0;36m" # cyan
	dslogo1="        /\         "
	dslogo2="       /',\        "
	dslogo3="      /   ,\       "
	dslogo4="     /  ,'  \      "
	dslogo5="    / ,'  ', \     "
	dslogo6="   /.'      '.\    "
	dslogo7="                   "
elif echo $NAME | grep -q 'Gentoo'; then
	dscolor="\033[0;35m" # purple
	dslogo1="         "
	dslogo2="   ---   "
	dslogo3="  \\ 0 \\  "
	dslogo4="  /__/   "
	dslogo5="         "
	dslogo6="         "
	dslogo7=$dslogo6
elif echo $NAME | grep -q 'Debian'; then
	dscolor="\033[0;31m" # red
	dslogo1="         "
	dslogo2="   -^-   "
	dslogo3="  ( @,)  "
	dslogo4="  '-_    "
	dslogo5="         "
	dslogo6="         "
	dslogo7=$dslogo6
elif echo $NAME | grep -q 'openSUSE'; then
	dscolor="\033[0;32m" # green
	dslogo1="         "
	dslogo2="    __   "
	dslogo3="  /~_')  "
	dslogo4="  @' '   "
	dslogo5="         "
	dslogo6="         "
	dslogo7=$dslogo6
elif echo $NAME | grep -q 'Fedora'; then
	dscolor="\033[0;34m" # blue
	dslogo1="         "
	dslogo2="   /'')  "
	dslogo3=" .-''-.  "
	dslogo4=" '-..-'  "
	dslogo5=" (__/    "
	dslogo6="         "
	dslogo7=$dslogo6
elif echo $NAME | grep -q 'Mint'; then
	dscolor="\033[0;32m" # blue
	dslogo1="         "
	dslogo2=" || -.-  "
	dslogo3=" ||_|||  "
	dslogo4=" \\____/  "
	dslogo5="         "
	dslogo6="         "
	dslogo7=$dslogo6
elif echo $NAME | grep -q 'Android'; then
	dscolor="\033[0;32m"
	dslogo1="                 _           _     _    "
	dslogo2="                | |         (_)   | |   "
	dslogo3="  __ _ _ __   __| |_ __ ___  _  __| |   "
	dslogo4=" / _/ | '_ \ / _. | '__/ _ \| |/ _. |   "
	dslogo5="| (_| | | | | (_| | | | (_) | | (_| |   "
	dslogo6=" \__,_|_| |_|\__,_|_|  \___/|_|\__,_|   "
	dslogo7="                                        "
else
	dscolor="\033[0;37m" # white
	dslogo1="            "
	dslogo2="    .~.     "
	dslogo3="    /V\     "
	dslogo4="   // \\\\\    "
	dslogo5="  /( _ )\   "
	dslogo6="   ^' '^    "
	dslogo7="            "
fi

# package manager
if echo $NAME | grep -q 'Android' && [ -f /bin/pm ]; then
	pm="$(pm list packages 2>/dev/null | wc -l) (apk)"
elif [ -f /usr/bin/ebuild ]; then
	pm="$(ls /var/db/pkg/*/*/BUILD_TIME 2>/dev/null | wc -l) (portage)"
elif [ -f /bin/pacman ]; then
	pm="$(pacman -Qq 2>/dev/null | wc -l) (pacman)"
elif [ -f /bin/rpm ]; then
	pm="$(rpm -qa 2>/dev/null | wc -l) (rpm)"
elif [ -f /bin/dpkg ]; then
	pm="$(apt list --installed 2>/dev/null | wc -l) (dpkg)"
else
	pm=Unknown
fi

# disk model
if [ -f /sys/block/sda/device/model ]; then
	diskc="$(cat /sys/block/sda/device/model)"
elif [ -f /sys/block/mmcblk0/device/name ]; then
	diskc="$(cat /sys/block/mmcblk0/device/name)"
else
	diskc=Unknown
fi

# board
if [ -d /sys/class/dmi/id ]; then
	hostv="$(cat /sys/class/dmi/id/product_name)"
	hostp="$(cat /sys/class/dmi/id/board_name)"
elif echo $NAME | grep -q 'Android'; then
	hostv=$(getprop ro.product.model)
else
	hostv=Unknown
fi

# initd
if [ -f /sbin/init ]; then
	init="$(readlink /sbin/init | sed "s/\/bin\///" | sed "s/\/sbin\///" | sed "s/\/usr//" | sed "s/\/lib//" | sed "s/\-init//" | sed "s/\/systemd\///")"
		if [ "$init" == "" ]; then
			init=initd
		fi
elif echo $NAME | grep -q 'Android'; then
	init=init.rc
fi

# cpu
cpu="$(grep "Hardware" /proc/cpuinfo | head -n1 | sed "s/Hardware	\: //")"

if [ "$cpu" == "" ]; then
	cpu="$(grep "model name" /proc/cpuinfo | head -n1 | sed "s/model name	\: //" | sed "s/ CPU//")"
		if [ "$cpu" == "" ]; then
			cpu=Unknown
		fi
fi

# hostname
if [ -f /bin/hostname ]; then
	host=$(hostname)
elif [ -f /proc/sys/kernel/hostname ]; then
	host="$(cat /proc/sys/kernel/hostname)"
else
	host=localhost
fi

# the meat and potatoes, actual fetch
USER=$(id -un)
kernel=$(uname -srm)
uptime="$(uptime -p | sed "s/up //")"
shell="$(echo "$SHELL" | sed "s/\/bin\///" | sed "s/\/usr//" | sed "s/\/system//")"
terma="$(readlink /proc/$$/fd/2 | sed "s/\/dev//" | sed "s/\///" | sed "s/\///")"

printf "${dscolor}${dslogo7}$USER@$host\n"
printf "${dscolor}${dslogo7}OS      ${nc} $NAME\n"
printf "${dscolor}${dslogo1}Kernel  ${nc} $kernel\n"
printf "${dscolor}${dslogo2}Cpu     ${nc} $cpu\n"
printf "${dscolor}${dslogo3}Host    ${nc} $hostv $hostp\n"
printf "${dscolor}${dslogo4}Init    ${nc} $init\n"
printf "${dscolor}${dslogo5}Uptime  ${nc} $uptime\n"
printf "${dscolor}${dslogo6}Shell   ${nc} $shell\n"
printf "${dscolor}${dslogo7}Pkgs    ${nc} $pm\n"
printf "${dscolor}${dslogo7}Term    ${nc} $terma\n"
printf "${dscolor}${dslogo7}Disk    ${nc} $diskc\n"
printf "${dslogo7}\033[0;31m● \033[0;32m● \033[0;33m● \033[0;34m● \033[0;35m● \033[0;36m● \033[0;37m●\033[0m\n"
