#!/bin/bash
cat << EOF
Hello there, please choose and option from this menu:
-----------------------------------------------------
1 -> Display your name

2 -> Display the hostname of this machine

3 -> Display ip address of this machine
EOF
read OPTION
case $OPTION in
1)
echo "What is your name?"
read $NAME
echo Hello $NAME
;;
2)
hostname
;;
3)
hostname -i
;;
*)
echo "You chose an invalid option."
esac