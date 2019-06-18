#/bin/bash

DIR=`dirname $0`

# Installing Git and the required packages to build bluez-tools
/usr/bin/apt update
/usr/bin/apt install -y dh-autoreconf git libglib2.0-dev libreadline-dev

# Clone the repository
/usr/bin/git clone https://github.com/khvzak/bluez-tools

# Changing directory to the git repository clone
cd "${DIR}/bluez-tools"

# Create the configure and start the configuration script
./autogen.sh

# Compiling
/usr/bin/make

# Installing
/usr/bin/make install

# Cleaning
/usr/bin/make clean

# Returning to previous folder
cd ..

# Copy the services to systemd
echo "Copying the bluetooth agent service to systemd"
/bin/cp "${DIR}/bluetooth.service" /lib/systemd/system/bluetooth.service
/bin/cp "${DIR}/blue-agent.service" /etc/systemd/system/blue-agent.service

# Add pi to the bluetooth user group
echo "Adding the PI user account to bluetooth system group"
/usr/sbin/adduser pi bluetooth

# Copy the PIN configuration file
echo "Copying the bluetooth pin configuration file"
/bin/cp "${DIR}/pin.conf" /etc/bluetooth/pin.conf
/bin/chmod 600 /etc/bluetooth/pin.conf

# Reload the systemd daemon and add the services
echo "Restarting the systemd daemon"
/bin/systemctl daemon-reload
/bin/systemctl enable blue-agent.service
/bin/systemctl start blue-agent.service

# Reboot the system
echo "Rebooting the system, press CTRL-C to cancel"
/bin/sleep 5
/sbin/reboot

exit 0
