#!/bin/bash
whoami
sudo kill -9  $(sudo lsof -t -i:3001)
nohup rails s -p 3001 -P 2003 & #rails s -e production -d #-b ec2-18-222-177-88.us-east-2.compute.amazonaws.com
