#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "[ERROR]: Plase run as root" && exit
fi

echo "[INFO]: Refreshing repository."
zypper refresh || exit

echo "[INFO]: Updating packages."
zypper update -y || exit

echo "[INFO]: Upgradeing distribution."
zypper dist-upgrade -y || exit

