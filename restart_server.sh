#!/bin/bash
whoami
sudo kill -9  $(sudo lsof -t -i:5005)
nohup rails s -b ec2-18-222-177-88.us-east-2.compute.amazonaws.com -p 5005 -P 2003 & #rails s -e production -d
