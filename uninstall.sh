#!/bin/bash

#############################################
# a2tm - Uninstaller for a2tm Tool Manager  #
# Date: 01-07-2022                          #
# Author: q3aql                             #
# Contact: q3aql@duck.com                   #
#############################################
VERSION="0.1"
M_DATE="010722"
LICENSE="GPL v2.0"

# Function to check root permissions.
function rootMessage() {
  mkdir -p /etc/root &> /dev/null
  administrador="$?"
  if [ ${administrador} -eq 0 ] ; then
    rm -rf /etc/root
  else
    echo ""
    echo "# a2tm ${VERSION} (${M_DATE}) (${LICENSE})"
    echo ""
    echo "# Administrator permissions are required."
    echo ""
    exit
  fi
}

# Show installer for a2tm
rootMessage
echo ""
echo "# a2tm uninstaller ${VERSION} (${M_DATE}) (${LICENSE})"
echo ""
rm -rf /usr/bin/a2tm
echo "+ Removed executable (/usr/bin/a2tm)."
if [ -f /etc/systemd/system/a2tm.service ] ; then
  rm -rf /etc/systemd/system/a2tm.service
  echo "+ Removed service (/etc/systemd/system/a2tm.service)."
  systemctl daemon-reload
fi
if [ -f /etc/init.d/a2tm ] ; then
  rm -rf /etc/init.d/a2tm
  echo "+ Removed service (/etc/init.d/a2tm)."
fi
echo "+ Uninstallation completed."
echo ""

