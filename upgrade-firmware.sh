#!/bin/bash

set -e

echo "Collecting inventory"
hp_system=$(dmidecode -t0 | awk '/Version:/{print $NF}')
hp_disk=$(ssacli ctrl all show config detail | grep -E '(ATA|HP)' | awk '/Model:/{print $NF}' | sort -u)
hp_raid=$(ssacli ctrl all show config | awk '/Smart Array/{print $4}')
# hp_nic = straight up install, no need to identify intel nics
hp_ilo=$(hponcfg -g | grep -oE 'iLO [0-9]+' | sed -r 's/\s+//g')

echo "Collecting inventory firmware packages"
hp_pkgs=()
hp_pkgs+=("$(dnf search $hp_system | awk '/firmware-system/{print $1}')")
hp_pkgs+=("$(dnf search $hp_disk | awk '/firmware-hdd/{print $1}')")
hp_pkgs+=("$(dnf search $hp_raid | awk '/firmware-smartarray/{print $1}')")
hp_pkgs+=("firmware-nic-intel")

# iLO has to be ignored, because the repo doesn't ship a recent enough sha512 package to complement the firmware
# hp_pkgs+=("$(dnf search $hp_ilo | awk '/firmware-ilo/{print $1}')")

echo "Downloading firmware packages"
dnf install --disablerepo="*" --enablerepo="hpe-fwpp" -y ${hp_pkgs[@]}

echo "Staging firmware upgrade"
yes | smartupdate upgrade --ignore-warnings --cleanup_onexit

echo "Firmware staged, please reboot host to apply"

