#!/bin/bash
#################################################
# check if local and remote files are identical #
# --------------------------------------------- #
# author:  Peter H. Späth                       #
# date:    April 01, 2025                       #
# version: 0.6                                  #
#################################################

#################################################
# initial settings
orgPath=`pwd`
cd /media/myBackup/ncp-backups
ssh pi@shomeserverbak.fritz.box sudo md5sum /media/myBackup/ncp-backups/* | sudo md5sum -c -
cd ${orgPath}
