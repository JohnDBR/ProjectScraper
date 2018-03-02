#!/bin/bash
apt-update 
apt-get install wget
apt-get install curl
apt-get install unzip 

wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip
unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/
unzip /tmp/chromedriver.zip chromedriver -d /usr/local/share/
unzip /tmp/chromedriver.zip chromedriver -d /usr/bin/

cd /usr/local/bin/
chmod +x chromedriver 
cd /usr/local/share/
chmod +x chromedriver
cd /usr/bin/
chmod +x chromedriver

curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /chrome.deb
sudo dpkg -i /chrome.deb || apt-get install -yf
rm /chrome.deb