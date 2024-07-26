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

	if [ -f /system/bin/getprop ]; then
		export NAME="Android $(getprop ro.build.version.release)"
	fi
else
	export NAME=Unknown
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
	dslogo1="         "
	dslogo2="  ('' )  "
	dslogo3="  |() |  "
	dslogo4="  (^(^)  "
	dslogo5="         "
	dslogo6="         "
	dslogo7=$dslogo6
fi

# package manager
if [ -f /usr/bin/ebuild ]; then
	export pm="$(ls /var/db/pkg/*/*/BUILD_TIME 2>/dev/null | wc -l) (portage)"
elif [ -f /bin/pacman ]; then
	export pm="$(pacman -Qq 2>/dev/null | wc -l) (pacman)"
elif [ -f /bin/rpm ]; then
	export pm="$(rpm -qa 2>/dev/null | wc -l) (rpm)"
elif [ -f /bin/dpkg ]; then
	export pm="$(apt list --installed 2>/dev/null | wc -l) (dpkg)"
elif echo $NAME | grep -q 'Android'; then
	export pm="$(pm list packages 2>/dev/null | wc -l) (apk)"
else
	export pm=Unknown
fi

# disk model
if [ -f /sys/block/sda/device/model ]; then
	export diskc="$(cat /sys/block/sda/device/model)"
elif [ -f /sys/block/mmcblk0/device/name ]; then
	export diskc="$(cat /sys/block/mmcblk0/device/name)"
else
	export diskc=Unknown
fi

# motherboard name
if [ -f /sys/class/dmi/id/product_name ]; then
	export hostv="$(cat /sys/class/dmi/id/product_name)"
elif echo $NAME | grep -q 'Android'; then
	export hostv=$(getprop ro.product.model)
else
	export hostv=Unknown
fi

# initd
if [ -f /sbin/init ]; then
	export init="$(readlink /sbin/init | sed "s/\/bin\///" | sed "s/\/sbin\///" | sed "s/\/usr//" | sed "s/\/lib//" | sed "s/\-init//" | sed "s/\/systemd\///" 2>/dev/null)"
elif echo $NAME | grep -q 'Android'; then
	export init=init.rc
else
	export init=Unknown
fi

# cpu
if echo $NAME | grep -q 'Android'; then
	export cpu="$(grep "Hardware" /proc/cpuinfo | head -n1 | sed "s/\Hardware	://" | sed "s/\ //" 2>/dev/null)"
else
	export cpu="$(grep "model name" /proc/cpuinfo | head -n1 | sed "s/\model name	://" | sed "s/\ //" | sed "s/\ CPU//" 2>/dev/null)"
fi

if [ "$cpu" == "" ]; then
	export cpu=Unknown
fi

# the meat and potatoes, actual fetch
host="$(hostname 2>/dev/null || cat /proc/sys/kernel/hostname 2>/dev/null)"
hostp=$(cat /sys/class/dmi/id/board_name 2>/dev/null)
kernel=$(uname -srm)
USER=$(id -un)
uptime="$(uptime -p | sed "s/up //")"
shell="$(echo "$SHELL" | sed "s/\/bin\///" | sed "s/\/usr//" | sed "s/\/system//" 2>/dev/null)"
terma="$(tty | sed "s/\/dev//" | sed "s/\///" | sed "s/\///" 2>/dev/null || readlink /proc/$$/fd/2 | sed "s/\/dev//" | sed "s/\///" | sed "s/\///" 2>/dev/null)"

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
