#!/bin/bash

cd

git clone https://www.github.com/Airblader/i3 i3-gaps

cd i3-gaps

autoreconf --force --install

rm -rf build/

mkdir -p build 

cd build/

../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers

make 

sudo make install 

cd dotfiles

echo 'rebooting, thank you for your patience'

reboot
