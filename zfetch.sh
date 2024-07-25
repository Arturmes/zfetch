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
	. /etc/os-release 2>/dev/null || export NAME="Unknown"
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


# source the config file
if [ "$colorsoff" = "" ]; then
	colorsoff=0
fi

[ -e /etc/zfetchrc ] && . /etc/zfetchrc 2> /dev/null
[ -e ~/.zfetchrc ] && . ~/.zfetchrc 2> /dev/null

# command line parameters
# if [ "$arg" = "" ]; then
# 	arg=""
# elif [ "$arg" = "nologo" ]; then
# 	unset dslogo
# elif [ "$arg" = "nofetch" ]; then
# 	printf "${dscolor}${dslogo1}\n${dslogo2}\n${dslogo3}\n${dslogo4}\n${dslogo5}\n${dslogo6}\n${nc}"
# 	exit
# fi

# package manager
if [ -f /usr/bin/ebuild ]; then
	export pm=$(echo "$(ls /var/db/pkg/*/*/BUILD_TIME 2>/dev/null | wc -l) (portage)")
elif [ -f /bin/pacman ]; then
	export pm=$(echo "$(pacman -Qq 2>/dev/null | wc -l) (pacman)")
elif [ -f /bin/rpm ]; then
	export pm=$(echo "$(rpm -qa 2>/dev/null | wc -l) (rpm)")
elif [ -f /bin/dpkg ]; then
	export pm=$(echo "$(apt list --installed 2>/dev/null | wc -l) (dpkg)")
else
	export pm=$(echo Unknown)
fi

# disk model
if [ -f /sys/block/sda/device/model ]; then
	export diskc="$(cat /sys/block/sda/device/model)"
elif [ -e /sys/block/mmcblk0/device/name ]; then
	export diskc="$(cat /sys/block/mmcblk0/device/name)"
else
	export diskc=$(echo Unknown)
fi

# motherboard name
if [ -f /sys/class/dmi/id/product_name ]; then
	export hostv="$(cat /sys/class/dmi/id/product_name)"
		if [ "$hostv" == "Default string" ]; then
			export hostv=$(echo Unknown)
		fi
else
	export hostv=$(echo Unknown)
fi

if [ -f /sys/class/dmi/id/board_name ]; then
	export hostp=$(cat /sys/class/dmi/id/board_name)
else
	export hostp=$(echo Unknown)
fi

# cpu arch
arch=$(uname -m)
if [ "$arch" == x86_64 ]; then
	export arch=$(echo)
fi

# initd
if [ -f /sbin/init ]; then
	export init="$(realpath /sbin/init | sed "s/\/bin\///" | sed "s/\/sbin\///" | sed "s/\/usr//" | sed "s/\/lib//" | sed "s/\-init//" | sed "s/\/systemd//")"
else
	export init=$(echo Unknown)
fi

# the meat and potatoes, actual fetch
host=$(cat /proc/sys/kernel/hostname)
kernel=$(sed "s/version // ; s/ (.*//" /proc/version)
uptime=$(uptime -p | sed "s/up //")
shell="$(printf "$SHELL" | sed "s/\/bin\///" | sed "s/\/usr//")"
session=$XDG_SESSION_TYPE
terma="$(tty | sed "s/\/dev//" | sed "s/\///" | sed "s/\///")"
cpu="$(grep "model name" /proc/cpuinfo | head -n1 | sed "s/\model name	://" | sed "s/\ //" | sed "s/\ CPU//")"

printf "${dscolor}${dslogo7}$USER@$host\n"
printf "${dscolor}${dslogo7}OS      ${nc} $NAME\n"
printf "${dscolor}${dslogo7}Kernel  ${nc} $kernel $arch\n"
printf "${dscolor}${dslogo1}Cpu     ${nc} $cpu\n"
printf "${dscolor}${dslogo2}Host    ${nc} $hostv $hostp\n"
printf "${dscolor}${dslogo3}Init    ${nc} $init\n"
printf "${dscolor}${dslogo4}Uptime  ${nc} $uptime\n"
printf "${dscolor}${dslogo5}Shell   ${nc} $shell\n"
printf "${dscolor}${dslogo6}Session ${nc} $session\n"
printf "${dscolor}${dslogo7}Pkgs    ${nc} $pm\n"
printf "${dscolor}${dslogo7}Term    ${nc} $terma\n"
printf "${dscolor}${dslogo7}Disk    ${nc} $diskc\n"

if [ "$colorsoff" != 1 ]; then
	printf "${dslogo7}\033[0;31m● \033[0;32m● \033[0;33m● \033[0;34m● \033[0;35m● \033[0;36m● \033[0;37m●\033[0m\n"
fi
