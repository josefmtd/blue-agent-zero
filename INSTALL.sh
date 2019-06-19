#/bin/bash

DIR=`dirname $0`

# Installing the required packages to build bluez-5.50
/usr/bin/apt update
/usr/bin/apt install -y libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev

# Download the BlueZ 5.50 source and unpack the tarball
/usr/bin/wget www.kernel.org/pub/linux/bluetooth/bluez-5.50.tar.xz
/bin/tar xvf bluez-5.50.tar.xz

# Changing the working directory to BlueZ-5.50
echo "Changing directory to bluez-5.50"
cd "${DIR}/bluez-5.50"

# Configure the compiler
"${DIR}/configure" --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var --disable-cups --disable-a2dp --disable-avrcp --disable-network --disable-hid --disable-hog

# Compile and install
/usr/bin/make
/usr/bin/make install

# Changing the directory back to blue-agent-zero
echo "Changing directory to blue-agent-zero"
cd ..

# Removing the source
/bin/rm -rf bluez-5.50
/bin/rm bluez-5.50.tar.xz

# Replace the bluetoothd
/bin/systemctl stop bluetooth.service
/bin/cp /usr/libexec/bluetooth/bluetoothd /usr/lib/bluetooth/bluetoothd

# Install the BlueZ tools
/usr/bin/apt install -y bluez-tools

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
