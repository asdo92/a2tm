#!/bin/bash

#############################################
# a2tm - Installer for a2tm Tool Manager    #
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
echo "# a2tm installer ${VERSION} (${M_DATE}) (${LICENSE})"
echo ""
cp -rf a2tm.py /usr/bin/a2tm
echo "+ Copied executable (/usr/bin/a2tm)."
chmod +x /usr/bin/a2tm
echo "+ Configuring execution permissions (/usr/bin/a2tm)."
if [ -f /usr/bin/systemctl ] ; then
  cp -rf service/a2tm.service /etc/systemd/system/
  echo "+ Created service (/etc/systemd/system/a2tm.service)."
  echo "+ INFO: Edit /etc/systemd/system/a2tm.service and change"
  echo "        the variable User=<USER>."
  systemctl daemon-reload
else
  if [ -d /etc/init.d ] ; then
    cp -rf service/a2tm-service.sh /etc/init.d/a2tm
    echo "+ Copied service (/etc/init.d/a2tm)."
  fi
fi
echo "+ Installation completed."
echo ""

