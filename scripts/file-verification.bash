#!/bin/bash
#############################################
# move ncp backup to backup server (remote) #
# ----------------------------------------- #
# author:  Peter H. Späth                   #
# date:    February 14, 2025                #
# version: 0.6                              #
#############################################

orgPath=`pwd`
cd /media/myBackup/ncp-backups
ssh pi@shomeserverbak.fritz.box sudo md5sum /media/myBackup/ncp-backups/* | sudo md5sum -c -
cd ${orgPath}