#!/bin/bash

#Package Name
pkgName="duplicity"
pflg=0
dflg=0
tflg=0

while getopts ":p:d:t:" opt; do
    case $opt in
    p)
        pflg=1
        passPhrase=$OPTARG
        echo "$passPhrase"
        ;;
    d)
        dflg=1
        direct=$OPTARG
        echo "$direct"
        ;;
    t)
        tflg=1
        backupType=$OPTARG
        echo "$backupType"
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

if [ $((pflg + tflg + dflg)) -eq 3 ]; then
    
    echo "Please specify the minute for the backup to happen"
    read minuteTime
    echo "Please specify the hour for the backup to happen"
    read hourTime
    echo "Please enter the target directory"
    read targDirect

    #Dpkg status redirected (stdin/stderr) to null (remove output)
    dpkg -s $pkgName &> /dev/null

    # $? returns value of last cmd, and -eq to check number is equal to 0 (-eq for integers)
    if [ $? -eq 0 ]; then
        echo "Duplicity is installed!"
    else
        sudo apt install "$pkgName"
    fi

    #Declaring array to be used as source
    declare -a incSource
    #Setting IFS delimeter
    IFS=','
    #Putting $direct into new array
    read -a dArray <<< $direct
    for item in "${dArray[@]}";
    do
    incSource+=(--include /$item)
    done
    
    truth=1
    while [ "$truth" -eq 1 ]; do
        echo
        echo "You have chosen to do a $backupType backup at $hourTime:$minuteTime. Please Confirm or Change Settings"
        select yn in "Yes" "No" "Settings"; do
            case $yn in
            Yes )
                echo "Confirmed, adding as crontab entry.";
                (crontab -l ; echo "$minuteTime $hourTime * * * PASSPHRASE=$passPhrase duplicity $backupType ${incSource[@]} --exclude '**' / file:///$targDirect >/dev/null 2>&1") | crontab -
                truth=0
                PASSPHRASE=""
                break;;
            No )
                echo "Exitting..."
                truth=0
                exit;;
            Settings )
                echo "Changing Settings";
                echo "Please specify the minute for the backup to happen"
                read minuteTime
                echo "Please specify the hour for the backup to happen"
                read hourTime
                echo "Please enter the target directory"
                read targDirect
                break;;
            esac
        done
    done

else
    echo "Make sure to enter arguements and use the flags"
    echo "-p for your passphrase"
    echo "-d for your directories to include with commas ',' as the deliminator"
    echo "-t please pass 'incremental' or 'full' for method of backup to be made"
fi
