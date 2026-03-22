#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt-get install build-essential autoconf automake libtool pkg-config libcurl4-openssl-dev libudev-dev libjansson-dev libncurses5-dev git libzip-dev -y
git clone https://github.com/TheRetroMike/cgminer-zeus.git
cd cgminer-zeus
sudo usermod -a -G dialout,plugdev $USER
sudo cp 01-cgminer.rules /etc/udev/rules.d/
CFLAGS="-O2 -march=native" ./autogen.sh
./configure --enable-scrypt
make
sudo mv cgminer /usr/local/bin/cgminer
cd ..
sudo rm -R cgminer-zeus
sudo echo '#!/bin/bash' | sudo tee /etc/startup.sh
sudo echo "screen -dmS miner sudo /usr/local/bin/cgminer --scrypt -o stratum+tcp://americas.mining-dutch.nl:8888 -u 05sonicblue.donation -p d=128 --zeus-chips 6 --zeus-clock 328" | sudo tee -a /etc/startup.sh
sudo chmod +x /etc/startup.sh
sudo crontab -l -u root | echo "@reboot sudo /etc/startup.sh" | sudo crontab -u root -
echo "------------------------------------------------"
echo "Zeus Miner Installation Complete"
echo "------------------------------------------------"
echo "To view miner, run: sudo screen -r miner"
echo "To edit mining pool params or configure more than one device (change zeus chip count), run: sudo nano /etc/startup.sh"
echo "------------------------------------------------"
