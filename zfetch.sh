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
# shellcheck disable=SC3010

# variables used: $NAME
# we do a check to see if $NAME is already set, if not, we try to detect OS
# ourselves
if [[ -f /etc/preloaded-classes ]] && command -v getprop >/dev/null 2>&1; then
	NAME="Android $(getprop ro.build.version.release)"
elif [[ -f /etc/os-release ]]; then
	. /etc/os-release
else
	NAME=Unknown
fi

# nc = no color
nc="\033[0m"

# logos
if echo "$NAME" | grep -q 'Arch'; then
	dscolor="\033[0;36m" # cyan
	dslogo1="        /\         "
	dslogo2="       /  \        "
	dslogo3="      /    \       "
	dslogo4="     /  ,.  \      "
	dslogo5="    / ,'  ', \     "
	dslogo6="   /.'      '.\    "
	dslogo7="                   "
elif echo "$NAME" | grep -q 'Artix'; then
	dscolor="\033[0;36m" # cyan
	dslogo1="        /\         "
	dslogo2="       /, \        "
	dslogo3="      /  ',\       "
	dslogo4="     /  ,'  \      "
	dslogo5="    / ,'  ', \     "
	dslogo6="   /.'      '.\    "
	dslogo7="                   "
elif echo "$NAME" | grep -q 'Manjaro'; then
	dscolor="\033[0;32m" # green
	dslogo1="  ||||||||| ||||   "
	dslogo2="  ||||||||| ||||   "
	dslogo3="  ||||      ||||   "
	dslogo4="  |||| |||| ||||   "
	dslogo5="  |||| |||| ||||   "
	dslogo6="  |||| |||| ||||   "
	dslogo7="                   "
elif echo "$NAME" | grep -q 'Raspbian'; then
	dscolor="\033[0;31m" # red
	dslogo1="     __  __     "
	dslogo2="    (_\\)(/_)    "
	dslogo3="    (_(__)_)    "
	dslogo4="   (_(_)(_)_)   "
	dslogo5="    (_(__)_)    "
	dslogo6="      (__)      "
	dslogo7="                "
elif echo "$NAME" | grep -q 'Debian'; then
	dscolor="\033[0;31m" # red
	dslogo1="    _____      "
	dslogo2="   /  __ \\     "
	dslogo3="  |  /    |    "
	dslogo4="  |  \\___-     "
	dslogo5="   -_          "
	dslogo6="    --_        "
	dslogo7="               "
elif echo "$NAME" | grep -q 'Gentoo'; then
	dscolor="\033[0;35m" # purple
	dslogo1="         "
	dslogo2="   ---   "
	dslogo3="  \\ 0 \\  "
	dslogo4="  /__/   "
	dslogo5="         "
	dslogo6="         "
	dslogo7=$dslogo6
elif echo "$NAME" | grep -q 'SUSE'; then
	dscolor="\033[0;32m" # green
	dslogo1="          "
	dslogo2="    __    "
	dslogo3="  /~_')   "
	dslogo4="  @' '    "
	dslogo5="          "
	dslogo6="          "
	dslogo7=$dslogo6
elif echo "$NAME" | grep -q 'Fedora'; then
	dscolor="\033[0;34m" # blue
	dslogo1="          "
	dslogo2="   /'')   "
	dslogo3=" .-''-.   "
	dslogo4=" '-..-'   "
	dslogo5=" (__/     "
	dslogo6="          "
	dslogo7=$dslogo6
elif echo "$NAME" | grep -q 'Mint'; then
	dscolor="\033[0;32m" # blue
	dslogo1="          "
	dslogo2=" || -.-   "
	dslogo3=" ||_|||   "
	dslogo4=" \\\\\____/  "
	dslogo5="          "
	dslogo6="          "
	dslogo7=$dslogo6
elif echo "$NAME" | grep -q 'Android'; then
	dscolor="\033[0;32m" # green
	dslogo1="    ;,           ,;    "
	dslogo2="     ';,.-----.,;'     "
	dslogo3="    ,'           ',    "
	dslogo4="   /    O     O    \\   "
	dslogo5="  |                 |  "
	dslogo6="  '-----------------'  "
	dslogo7="                       "
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
if echo "$NAME" | grep -q 'Android' && command -v cmd >/dev/null 2>&1; then
	pm="$(cmd package list packages 2>/dev/null | wc -l) (apk)"
elif command -v ebuild >/dev/null 2>&1; then
	pm="$(find /var/db/pkg/*/*/ -name BUILD_TIME 2>/dev/null | wc -l) (portage)"
elif command -v pacman >/dev/null 2>&1; then
	pm="$(pacman -Qq 2>/dev/null | wc -l) (pacman)"
elif command -v rpm >/dev/null 2>&1; then
	pm="$(rpm -qa 2>/dev/null | wc -l) (rpm)"
elif command -v dpkg >/dev/null 2>&1; then
	pm="$(apt list --installed 2>/dev/null | wc -l) (dpkg)"
else
	pm=Unknown
fi

# disk model
if [[ -r /sys/block/sda/device/model ]]; then
	diskc="$(cat /sys/block/sda/device/model)"
elif [[ -r /sys/block/mmcblk0/device/name ]]; then
	diskc="$(cat /sys/block/mmcblk0/device/name)"
else
	diskc=Unknown
fi

# board
if [[ -d /sys/class/dmi/id ]]; then
	hostv="$(cat /sys/class/dmi/id/product_name) $(cat /sys/class/dmi/id/board_name)"
elif echo "$NAME" | grep -q 'Android'; then
	hostv="$(getprop ro.product.brand) $(getprop ro.product.model)"
elif [[ -r /sys/firmware/devicetree/base/model ]]; then
	hostv="$(cat < /sys/firmware/devicetree/base/model | tr -d '\0')"
else
	hostv=Unknown
fi

# initd
if [[ -L /sbin/init ]]; then
	init="$(readlink /sbin/init | sed "s/\/bin\///" | sed "s/\/sbin\///" | sed "s/\/usr//" | sed "s/\/lib//" | sed "s/\-init//" | sed "s/\/systemd\///" | sed "s/\..//")"
		if [[ "$init" == "" ]]; then
			init=initd
		fi
elif echo "$NAME" | grep -q 'Android'; then
	init=init.rc
else
	init=Unknown
fi

# cpu
cpu="$(awk -F '\\s*: | @' \
                            '/model name|Hardware|Processor|^cpu model|chip type|^cpu type/ {
                            cpu=$2; if ($1 == "Hardware") exit } END { print cpu }' /proc/cpuinfo 2>/dev/null)"	# part from neofetch

if [[ "$cpu" == "" ]] || [[ -z "$cpu" ]]; then
	if echo "$NAME" | grep -q 'Android'; then
		cpu="$(getprop ro.soc.manufacturer) $(getprop ro.soc.model)"
	elif command -v lscpu >/dev/null 2>&1; then
		cpu="$(LC_ALL=C lscpu | awk -F ':' '/Model name/{print $2}' | sed "s/^[ \t]*//")"
	else
		cpu=Unknown
	fi
fi

# ram
if command -v free >/dev/null 2>&1; then
	memory=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
elif [[ -r /proc/meminfo ]]; then
	memory="$(awk '/MemTotal/ {total=$2} /MemAvailable/ {available=$2} END {used=total-available; printf "%.1f MiB / %.1f MiB", used/1024, total/1024}' /proc/meminfo)"
else
	memory=Unknown
fi

# shell
if command -v basename >/dev/null 2>&1; then
	shell=$(basename "$SHELL")
else
	shell="$(echo "$SHELL" | sed "s/\/bin\///" | sed "s/\/sbin\///" | sed "s/\/usr//" | sed "s/\/system//")"
fi

# virtual terminal
if [[ -L /proc/$$/fd/2 ]]; then
	termv="$(readlink /proc/$$/fd/2 | sed "s/\/dev//" | sed "s/\///" | sed "s/\///")"
else
	termv=Unknown
fi

if [[ -f /proc/$PPID/status ]]; then
	termp="$(grep PPid /proc/$PPID/status | sed "s/PPid:	//")"
		if [[ -d "/proc/$termp" ]]; then
			terma="$(cat < /proc/"$termp"/comm | tr -d '\0')"
		else
			terma=$termv
		fi
elif [[ -z "$terma" ]] || [[ "$terma" == "" ]]; then
	terma=$termv
fi

# the meat and potatoes, actual fetch
USER=$(id -un)
host=$(uname -n)
kernel=$(uname -sr)
uptime="$(uptime -p | sed "s/up //")"

printf "${dscolor}${dslogo7}$USER@$host\n"
printf "${dscolor}${dslogo7}OS      ${nc} $NAME\n"
printf "${dscolor}${dslogo1}Kernel  ${nc} $kernel\n"
printf "${dscolor}${dslogo2}Cpu     ${nc} $cpu\n"
printf "${dscolor}${dslogo3}Host    ${nc} $hostv\n"
printf "${dscolor}${dslogo4}Init    ${nc} $init\n"
printf "${dscolor}${dslogo5}Memory  ${nc} $memory\n"
printf "${dscolor}${dslogo6}Uptime  ${nc} $uptime\n"
printf "${dscolor}${dslogo7}Shell   ${nc} $shell\n"
if [ "$pm" != "Unknown" ]; then
	printf "${dscolor}${dslogo7}Pkgs    ${nc} $pm\n"
fi
printf "${dscolor}${dslogo7}Term    ${nc} $terma\n"
if [ "$diskc" != "Unknown" ]; then
	printf "${dscolor}${dslogo7}Disk    ${nc} $diskc\n"
fi
printf "${dslogo7}\033[0;31m● \033[0;32m● \033[0;33m● \033[0;34m● \033[0;35m● \033[0;36m● \033[0;37m●\033[0m\n"
