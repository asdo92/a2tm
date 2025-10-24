#!/bin/bash

#############################################################
# a2tm - Installer for a2tm Tool Manager (erlang version    #
# Date: 24-10-2025                                          #
# Author: asdo92                                            #
# Contact: asdo92@duck.com                                  #
#############################################################
VERSION="0.1"
M_DATE="241025"
LICENSE="GPL v2.0"

# Show installer for a2tm
current_dir=$(pwd)
echo ""
echo "# a2tm installer (erlang version) ${VERSION} (${M_DATE}) (${LICENSE})"
echo ""
mkdir -p ~/.local/bin/a2tm-erl
cp -rf a2tm.erl ~/.local/bin/a2tm-erl/
echo "+ Copied executable (~/.local/bin/a2tm-erl/a2tm.erl)."
cd ~/.local/bin/a2tm-erl
echo "+ Building erlang bycote (~/.local/bin/a2tm-erl/a2tm.beam)"
erlc -W0 a2tm.erl
echo "+ Creating run script (~/.local/bin/a2tm_erl)."
echo '#!/bin/bash' > ~/.local/bin/a2tm_erl
echo "" >> ~/.local/bin/a2tm_erl
echo 'cd ~/.local/bin/a2tm-erl' >> ~/.local/bin/a2tm_erl
echo 'if [ ${1} == "run_service" ] ; then' >> ~/.local/bin/a2tm_erl
echo '  erl -noshell -s a2tm run_service -s init stop' >> ~/.local/bin/a2tm_erl
echo 'else' >> ~/.local/bin/a2tm_erl
echo '  erl -noshell -s a2tm main -s init stop' >> ~/.local/bin/a2tm_erl
echo 'fi' >> ~/.local/bin/a2tm_erl
chmod +x ~/.local/bin/a2tm_erl
if [ -f /usr/bin/systemctl ] ; then
  cd ${current_dir}
  mkdir -p ~/.config/systemd/user 
  cp -rf service/a2tm-erl.service ~/.config/systemd/user/
  echo "+ Created service (~/.config/systemd/user/a2tm-erl.service)."
  sed -i '/ExecStart=/d' ~/.config/systemd/user/a2tm-erl.service 
  sed -i '/ExecStop=/d' ~/.config/systemd/user/a2tm-erl.service 
  echo "ExecStart=${HOME}/.local/bin/a2tm_erl run_service" >> ~/.config/systemd/user/a2tm-erl.service
  echo "ExecStop=/usr/bin/killall aria2c" >> ~/.config/systemd/user/a2tm-erl.service
  systemctl --user daemon-reload
fi
echo "+ Installation completed."
echo ""

