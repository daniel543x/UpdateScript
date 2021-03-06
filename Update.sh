#!/bin/bash

function APT()
{
	dpkg -s aptitude &> /dev/null || apt update >> /var/log/upgrade/upgrade_log.txt; apt install -y aptitude >> /var/log/upgrade/upgrade_log.txt

	echo '[INFO]: Searching update.'
	aptitude update >> /var/log/upgrade/upgrade_log.txt || exit;

	echo '[INFO]: Upgrading packages.'
	aptitude safe-upgrade -y >> /var/log/upgrade/upgrade_log.txt || exit;

	echo "[INFO]: Cleaning after updating."
	aptitude autoclean -y >> /var/log/upgrade/upgrade_log.txt || exit;
	aptitude clean -y >> /var/log/upgrade/upgrade_log.txt || exit;
	apt autoremove -y >> /var/log/upgrade/upgrade_log.txt || exit;
}

function ZYPPER()
{
	echo "[INFO]: Refreshing repository."
	zypper --non-interactive refresh >> /var/log/upgrade/upgrade_log.txt || exit

	echo "[INFO]: Updating packages."
	zypper --non-interactive update -y >> /var/log/upgrade/upgrade_log.txt || exit

	echo "[INFO]: Upgradeing distribution."
	zypper --non-interactive dist-upgrade -y >> /var/log/upgrade/upgrade_log.txt || exit

	echo "[INFO]: Cleaning cache."
	zypper --non-interactive clean >> /var/log/upgrade/upgrade_log.txt || exit

	echo "[INFO]: Removeing old kernels."
	zypper --non-interactive purge-kernels >> /var/log/upgrade/upgrade_log.txt || exit
}

function FLATPAK()
{
	flatpak update -y >> /var/log/upgrade/upgrade_log.txt 
}

if [ "$EUID" -ne 0 ]; then 
    echo "[ERROR]: Please run as root" && exit;
fi

echo "[INFO]: Checking connect to internet."
ping 9.9.9.9 -c 6 &> /dev/null || echo "[ERROR]: Have you internet conetion?" && exit;

ls /tmp/upgrade.lock &> /dev/null && echo "[WARRNING]: Another instance this scrypt is active!" && exit;

touch /tmp/upgrade.lock &> /dev/null || exit;

ls /var/log/upgrade/ &> /dev/null || mkdir -p /var/log/upgrade/ || exit;
ls /var/log/upgrade/upgrade_log.txt &> /dev/null || touch /var/log/upgrade/upgrade_log.txt || exit;

echo "[INFO]: Searching package menagers."

if [ -e /bin/apt ]; then
	APT
fi

if [ -e /bin/flatpak ]; then
	FLATPAK
fi

if [ -e /bin/zypper ]; then
	ZYPPER
fi

rm /tmp/upgrade.lock
