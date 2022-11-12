#!/bin/bash
echo "Who is trying to get the uptime?"
read USERNAME
showuptime(){
local up=$(uptime -p | cut -c4-)
local since=$(uptime -s)
cat << EOF
----------
This machine has been up for ${up}

It has been running since ${since}

----------
EOF
if [ ${USERNAME,,} = "herbert" ]; then
    return 0
else

    return 1
fi
}
showuptime
if [ $? = 1 ]; then
    echo "Someone unknown requested the uptime!"
fi