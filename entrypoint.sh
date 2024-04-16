#!/bin/bash

# exit on errors
set -e

# check if the FWPP token was provided
if [[ -z "$FWPP_TOKEN" ]]; then
	# disable the repo
	sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/hpe-fwpp.repo
else
	# write the FWPP token to dnf vars so the repo can read it
	echo "$FWPP_TOKEN" > /etc/dnf/vars/fwpptoken
fi

# support proxies
if [[ -n "$PROXY" ]]; then
	echo "proxy=$PROXY" >> /etc/dnf/dnf.conf
fi

# shorthand for firmware upgrades
if [[ "${1,,}" = "upgrade" ]]; then
	if [[ -z "$FWPP_TOKEN" ]]; then
		echo "Missing envvar 'FWPP_TOKEN', required to authenticate with FWPP repo."
		echo "https://downloads.linux.hpe.com/sdr/project/fwpp/"
		exit 1
	fi

	bash /upgrade-firmware.sh
fi

exec "$@"
