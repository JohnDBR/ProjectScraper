#!/bin/bash
whoami
sudo kill -9  $(sudo lsof -t -i:3000)
rails s -e production -d
