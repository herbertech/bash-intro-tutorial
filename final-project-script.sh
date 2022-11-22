#!/bin/bash

# JARVIS is an all-in-one tool to easily administer your Linux machine.
# This tool is very simple and modular, you can add your own functions
# so you don't need to remember all the commands and parameters.

###HELP FUNCTION


##TODO: #1 Add countdown timer to final project
##TODO: #2 Add logging to the final project
##TODO: #3 Add positional argument function to final project


logfilelocation="/home/herbert/logs/bashlogs.log"
showhelp(){
cat << EOF
*****************************************************
Hello commander, these are the arguments you can use:
-----------------------------------------------------

help        -> Shows this help message
ip          -> Display the ip address of this machine
hostname    -> Display the hostname of this machine
uptime      -> Display how long this machine has been running.
datetime    -> Display the time and date
replacewords-> Replace words in a file
readelement -> Read the nth element of a text file
countdown   -> Countdown a number of seconds

-----------------------------------------------------
*****************************************************
EOF
}

##SHOW IP ADDRESS FUNCTION
showip(){
echo "This machine's IP address is:"
hostname -I | awk '{print $1}'
}

##SHOW HOSTNAME FUNCTION
showhost(){
echo "This machines hostname is:"
cat /etc/hostname
}

##SHOW UPTIME FUNCTION
showuptime(){
up=$(uptime -p | cut -c4-)
since=$(uptime -s)
cat << EOF
----------
This machine has been up for ${up}

It has been running since ${since}
----------
EOF
}

showdatetime(){
    TZ='Europe/Brussels' date "+%d-%m-%y - %H:%M:%S"
}

replacewords(){
    echo "Please the file you want to change words for."
    read file
    echo "What word do you want to change?"
    read word1
    echo "What do you want the word to be?"
    read word2
    echo "Do you want a backup of the original file?"
    while true; do
        read -p "Do you want to create a backup?" backup
        case $backup in
            [Yy]* ) backupmode="-i.backup"; break;;
            [Nn]* ) backupmode="";;
        esac
    done
    sed $backupmode "s/$word1/$word2/g" $file
}

readelement(){
    re='^[0-9]+$'
    read -p "What file would you like to read from?" file
    wordcount=$(wc -w < $file)
    while true; do
        read -p "There are $wordcount words in this file. Enter a number between 1 and $wordcount to read a word." position
        if ! [[ $position =~ $re ]]
        then
            echo "That's not a number!"
        elif [ $position -gt $wordcount ]
        then
            echo "There aren't that many words in this file."
        else
            awk -v x=$position '{print $x}' $file
            break
        fi
    done
}

countdown(){
    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]]
    then
        echo "Enter a number after countdown to count down in seconds."
    else
        count=$1
        for i in $(seq $1); do
            echo $count
            count="$(($count-1))"
            sleep 1
        done
    fi
}

case $1 in
    "help")
    showhelp
    ;;
    "ip")
    showip
    ;;
    "hostname")
    showhost
    ;;
    "uptime")
    showuptime
    ;;
    "datetime")
    showdatetime
    ;;
    "replacewords")
    replacewords
    ;;
    "readelement")
    readelement
    ;;
    "countdown")
    countdown $2
    ;;
    *)
    showhelp
    ;;
esac

if ! [ -z $1 ]
then
    echo "$(showdatetime) | User $(whoami) ran $(basename $0) with option $1" >> $logfilelocation
fi