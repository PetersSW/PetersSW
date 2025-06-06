#!/bin/bash
#############################################
# move ncp backup to backup server (remote) #
# ----------------------------------------- #
# author:  Peter H. Späth                   #
# date:    April 01, 2025                   #
# version: 3.1                              #
#############################################

#############################################
# initial settings
domain='fritz.box'
errCode=0
localBackupDir='/media/myBackup/ncp-backups'
localBackupFile='ncp-bak.bash'
localHost=`hostname`.${domain}
localUser=`whoami`
logFile='/home/'${localUser}'/backup/ncp-bak.log'
remoteBackupDir='/media/myBackup/ncp-backups'
remoteHost='SHomeServerBak.'${domain}
remoteUser='pi'

#############################################
# start transfer
echo -e "`date`\tbackup transfer started" &>>${logFile}

# are source and targer identical?
if [ "${localHost}:${localBackupDir}" == "${remoteHost}:${remoteBackupDir}" ]
then
   errCode=1
   echo -e "`date`\terrCode ${errCode} source and target are identical" &>>${logFile}
fi

# is remote host reachable?
ping -qc3 ${remoteHost} &>>/dev/null
if [ $? -gt 0 ] && [ ${errCode} -eq 0 ]
then
   errCode=2
   echo -e "`date`\terrCode ${errCode} remote host is unreachable!" &>>${logFile}
fi 
 
# search new file (file does not exist remote)
if [ ${errCode} ]
then
   missingFiles=( `comm -23 <(ls ${localBackupDir} | sort) <(ssh ${remoteUser}@${remoteHost} ls ${remoteBackupDir} | sort)` )
   if [ ${#missingFiles[@]} -eq 0 ]
   then
      # no files missing
      echo -e "`date`\terrCode ${errCode} no files to transfer!" &>>${logFile}
   else
      echo -e "`date`\terrCode ${errCode} number of missing files: ${#missingFiles[@]}" &>>${logFile}
      for file in ${missingFiles[@]}
      do
         # is enough remote storage available
         remoteStorageAvailable=$((1024 * `ssh ${remoteUser}@${remoteHost} df --output=avail ${remoteBackupDir} | tail -n1`))
         fileSize=`stat -c '%s' ${localBackupDir}/${file}`
         if [ ${remoteStorageAvailable} -gt $((2 * ${fileSize})) ]
         then 
            echo -e "`date`\terrCode ${errCode} transfer of file ${file} started" &>>${logFile}
            # copy backup to remote server
            scp -Bqp ${localBackupDir}/${file} ${remoteUser}@${remoteHost}:${remoteBackupDir} &>>${logFile}
            if [ $? -gt 0 ]
            then
               errCode=4
               echo -e "`date`\terrCode ${errCode} transfer of file ${file} aborted" &>>${logFile}
            else
               echo -e "`date`\terrCode ${errCode} transfer of file ${file} ended" &>>${logFile}
            fi
         else
            errCode=3
            echo -e "`date`\terrCode ${errCode} not enough remote storage to store ${file}" &>>${logFile}
         fi
      done
   fi
fi

#############################################
# end transfer
echo -e "`date`\tbackup transfer ended" &>>${logFile}
