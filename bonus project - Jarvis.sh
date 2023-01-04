#!/bin/bash

# JARVIS is an all-in-one tool to easily administer your Linux machine.
# This tool is very simple and modular, you can add your own functions
# so you don't need to remember all the commands and parameters.


## In this if-statement we check if the logs directory exists, and create it if it doesn't.
## Then, we set the location in a variable.

if [ -d "/home/$(whoami)/logs/" ]
then
    logfilelocation="/home/$(whoami)/logs/bashlogs.log"
else
    echo "Logfile directory does not exist, creating directory"
    mkdir "/home/$(whoami)/logs"
    logfilelocation="/home/$(whoami)/logs/bashlogs.log"
fi

###HELP FUNCTION
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

## In this function, we use a while loop. This is like a for loop, but it keeps looping until a condition is met.
## We will keep asking for an input until it is either Y/y or N/n
## Once we have the correct input, we will break the while loop and set the backupmode
replacewords(){
    echo "Please the file you want to change words for."
    read file
    echo "What word do you want to change?"
    read word1
    echo "What do you want the word to be?"
    read word2
    echo "Do you want a backup of the original file?"
    while true; do
        read -p "Do you want to create a backup? (Y/N)" backup
        case $backup in
            [Yy]* ) backupmode="-i.backup"; break;;
            [Nn]* ) backupmode=""; break;;
        esac
    done
    sed $backupmode "s/$word1/$word2/g" $file
}

## In this function, we use a regular expression that will make sure the input is numerical to avoid errors.
## In the first if statement, we check if the file exists and if it does we get the word count.
## In the next if statement we  use the -lt operator, meaning lesser than, to check if it isn't an empty file.
## Then, we start our wile loop to ask which word we want to read. Using our regular expression,
## we make sure the input is numerical. If the input is not, we ask again for input using the while loop.
## The, if the user enters a number larger than the wordcount, we tell it that there aren't that many words in the file.
## And only after multiple checks, we can finally print the correct word using AWK. Take note of how we change all the
## newline characters ('\n') with a space (' ') using the tr command before we pass the output to AWK.
## This is because AWK will look at new lines a columns, printing out the content of a specific column rather than
## the word at a position, separated by a space. 

readelement(){
    re='^[0-9]+$'
    read -p "What file would you like to read from? " file
    if ! [[ -f $file ]]
    then
        echo "That file does not exist!"
        exit
    fi
    wordcount=$(wc -w < $file)
    if [ $wordcount -lt 1 ]
    then
        echo "There are no words in this file!"
        exit
    fi
    while true; do
        read -p "There are $wordcount words in this file. Enter a number between 1 and $wordcount to read a word. " position
        if ! [[ $position =~ $re ]]
        then
            echo "That's not a number!"
        elif [ $position -gt $wordcount ]
        then
            echo "There aren't that many words in this file."
        else
            cat $file | tr '\n' ' ' | awk -v x=$position '{print $x}'
            break
        fi
    done
}

## In our countdown function, we define the same regular expression because we want the amount of seconds
## to count down. This covers empty arguments as well, because an empty string is also not a number.
## We get the input, and we start the count down with a for loop, printing every counted down.

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
        echo "Done counting!"
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

## Last but not least, we log all the activity with our own function showdatetime to get the day and time of the time
## of execution. We supply the use who ran the script, as well as the script itself (basename $0) along with the option.

if ! [ -z $1 ]
then
    echo "$(showdatetime) | User $(whoami) ran $(basename $0) with option $1" >> $logfilelocation
fi