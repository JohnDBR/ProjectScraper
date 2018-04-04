#!/bin/bash
cd projectscraper/
git pull
fuser -n tcp -k 5005
nohup rails s -b ec2-18-188-42-115.us-east-2.compute.amazonaws.com -p 5005 -P 2003 &
