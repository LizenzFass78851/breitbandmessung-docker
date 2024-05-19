#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
#set -u # Treat unset variables as an error.

# YAML-Output as String
yaml_output=$(curl -sSL $YAML_LINK)

# Extract Version and SHA512-Sum
APP_VERSION=$(echo "$yaml_output" | grep -m 1 -oP 'version: \K.*')
APP_SHA512SUM=$(echo "$yaml_output" | grep -m 1 -oP 'sha512: \K.*')
set-cont-env APP_VERSION "$(echo "$APP_VERSION")"
set-cont-env APP_SHA512SUM "$(echo "$APP_SHA512SUM")"

# check if /VERSION File exists, --> only installing on first container start, afterwards skip ...
if [ -f "/VERSION" ]
then
    APP_LOCAL_VERSION=$(cat /VERSION)
    if [ "$APP_VERSION" = "$APP_LOCAL_VERSION" ]; then
      echo "App already installed, not installing again."
      echo "Version is: $APP_LOCAL_VERSION"
      exit 0
    else
      echo "App Update detected"
      echo "Version is: $APP_LOCAL_VERSION"
      echo "Update Version is: $APP_VERSION"
    fi
fi


# Otherwiese install breitbandmessung-dektop ...
#echo "Installing Version $APP_VERSION (sha512:$APP_SHA512SUM)"
echo "Installing Version $APP_VERSION"

# Download latest breitbandmessung-app
curl "https://download.breitbandmessung.de/bbm/Breitbandmessung-$APP_VERSION-linux.deb" -o Breitbandmessung-$APP_VERSION-linux.deb
#echo "$APP_SHA512SUM  Breitbandmessung-$APP_VERSION-linux.deb" | sha512sum -c
#retVal=$?
#if [ $retVal -ne 0 ]; then
#    echo "Checksum mismatch"
#else
#    echo "Checksum matches, installing ..."
#fi
echo "installing ..."

# Install .deb file
sed -i '/messagebus/d' /var/lib/dpkg/statoverride   # needed because group does not exist at this time
dpkg -i "Breitbandmessung-$APP_VERSION-linux.deb"


# Save version info in /VERSION file
echo $APP_VERSION > /VERSION
# Delete install package
rm "Breitbandmessung-$APP_VERSION-linux.deb"

