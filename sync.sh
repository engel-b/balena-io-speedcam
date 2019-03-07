#!/bin/bash
progName=$(basename -- "$0")

lockFileCheck=false      # true= Checks for pi-timolo.sync file. false = No Check (case sensitive)
rcloneName="gdrive"     # Name of Remote Storage Service
syncRoot="/home/pi/speed-camera"   # Root Folder to Start
rcloneParam="move -L"    # rclone option to perform  Eg  sync, copy, move


# Display Users Settings
echo "----------- SETTINGS -------------
lockFileCheck : $lockFileCheck
rcloneName    : $rcloneName
syncRoot      : $syncRoot
rcloneParam   : $rcloneParam   (Options are sync, copy or move)
---------------------------------"

lockFilePath="/home/pi/rclone.sync"

cd $syncRoot   # Change to local rclone root folder

/usr/bin/rclone listremotes | grep "$rcloneName"  # Check if remote storage name exists
if [ $? == 0 ]; then    # Check if listremotes found anything
    if $lockFileCheck ; then
        if [ -f "$lockFilePath" ] ; then  # Check if sync lock file exists
            echo "INFO  : Found Lock File $lockFilePath"
            echo "        rclone $rcloneParam is Required."
        else
            echo "INFO  : Lock File Not Found: $lockFilePath"
            echo "        rclone $rcloneParam is Not Required."
            echo "Exiting sync"
            exit 0
        fi
    fi

    echo "INFO  : /usr/bin/rclone $rcloneParam -v media/recent $rcloneName:speedcam/recent"
    /usr/bin/rclone $rcloneParam -v media/recent $rcloneName:speedcam/recent
    echo "INFO  : /usr/bin/rclone $rcloneParam -v media/images $rcloneName:speedcam/images"
    /usr/bin/rclone $rcloneParam -v media/images $rcloneName:speedcam/images

    if [ ! $? -eq 0 ]; then
        echo "---------------------------------------------------"
        echo "ERROR : rclone $rcloneParam Failed."
        echo "        Review rclone %rcloneParam Output for Possible Cause."
    else
        echo "INFO  : rclone $rcloneParam Successful ..."
        if $lockFileCheck ; then
            if [ -f "$lockFilePath" ] ; then
                echo "INFO  : Delete File $lockFilePath"
                rm -f $lockFilePath
            fi
        fi
    fi
else
    echo "ERROR : rcloneName=$rcloneName Does not Exist"
    rclone listremotes
fi
