#!/bin/bash

cd ~/Downloads/
git clone https://aur.archlinux.org/chromedriver.git 
cd chromedriver

makepkg
sudo cp ~/Downloads/chromedriver/pkg/chromedriver/usr/bin/chromedriver /usr/bin/
sudo cp ~/Downloads/chromedriver/pkg/chromedriver/usr/bin/chromedriver /usr/local/bin/
sudo cp ~/Downloads/chromedriver/pkg/chromedriver/usr/bin/chromedriver /usr/local/share/
sudo chmod +x /usr/bin/chromedriver 
sudo chmod +x /usr/local/bin/chromedriver
sudo chmod +x /usr/local/share/chromedriver

sudo rm -rf ~/Downloads/chromedriverS

echo -e "Now install google-chrome...\n"

# There are some tools to install .deb files, i dont even know if i really need the .deb file... 
# I'm just istalling chrome... So pls just install chrome...

# You can uncomment this section... Just this section 
# cd ~/Downloads
# mkdir chrome
# cd chrome
# sudo curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o ~/Downloads/chrome/chrome.deb
# sudo ar x chrome.deb
# sudo tar xf data.tar.xz 

# This is what you should do now... but if you try to uncomment and run this... you are going to have a big mess... 
# You will never know how much you harm manjaro and you will never know how much you fix it...

# sudo cd ~/Downloads/chrome/etc
# sudo mv * /etc/
# sudo cd ~/Downloads/chrome/opt
# sudo mv * /opt/
# sudo cd ~/Downloads/chrome/usr/bin
# sudo mv * /usr/bin/
# sudo cd ~/Downloads/chrome/usr/share/appdata
# sudo mv * /usr/share/appdata/
# sudo cd ~/Downloads/chrome/usr/share/applications
# sudo mv * /usr/share/applications/
# sudo cd ~/Downloads/chrome/usr/share/doc
# sudo mv * /usr/share/doc/
# sudo cd ~/Downloads/chrome/usr/share/gnome-control-center
# sudo mv * /usr/share/gnome-control-center/
# sudo cd ~/Downloads/chrome/usr/share/man/man1
# sudo mv * /usr/share/man/man1
# sudo cd ~/Downloads/chrome/usr/share/menu
# sudo mv * /usr/share/menu/
