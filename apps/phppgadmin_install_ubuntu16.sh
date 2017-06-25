#!/bin/bash

# Tech and Me © - 2017, https://www.techandme.se/

# shellcheck disable=2034,2059
true
# shellcheck source=lib.sh
. <(curl -sL https://raw.githubusercontent.com/nextcloud/vm/postgresql/lib.sh)

# Check for errors + debug code and abort if something isn't right
# 1 = ON
# 0 = OFF
DEBUG=0
debug_mode

# Check if root
if ! is_root
then
    printf "\n${Red}Sorry, you are not root.\n${Color_Off}You must type: ${Cyan}sudo ${Color_Off}bash %s/phppgadmin_install_ubuntu16.sh\n" "$SCRIPTS"
    sleep 3
    exit 1
fi

# Check that the script can see the external IP (apache fails otherwise)
if [ -z "$WANIP4" ]
then
    echo "WANIP4 is an emtpy value, Apache will fail on reboot due to this. Please check your network and try again"
    sleep 3
    exit 1
fi

# Check Ubuntu version
if [ "$OS" != 1 ]
then
    echo "Ubuntu Server is required to run this script."
    echo "Please install that distro and try again."
    sleep 3
    exit 1
fi


if ! version 16.04 "$DISTRO" 16.04.4; then
    echo "Ubuntu version seems to be $DISTRO"
    echo "It must be between 16.04 - 16.04.4"
    echo "Please install that version and try again."
    exit 1
fi

echo
echo "Installing and securing phpPGadmin..."
echo "This may take a while, please don't abort."
echo

# Install phpPGadmin
apt update -q4 & spinner_loading
apt install -y -q \
    php-gettext \
    phppgadmin

# Allow local access
sed -i "s|Require local|Require ip $GATEWAY/24|g" /etc/apache2/conf-available/phppgadmin.conf

if ! service apache2 restart
then
    echo "Apache2 could not restart..."
    echo "The script will exit."
    exit 1
fi