#!/bin/bash

module is-loaded redis || ( echo "No redis module loaded!"; exit 1 )
module load waitpid

set -x

# echo 'save ""' > tmp_nosave.conf
# redis-server &
# srvpid=$!

echo Initializing...

redis-cli DEL mystream
redis-cli XGROUP CREATE mystream mygroup $ MKSTREAM

echo Spawning three clients

redis-cli xreadgroup GROUP mygroup myuser COUNT 10 BLOCK 10000 STREAMS mystream \> &
cl1pid=$!
redis-cli xreadgroup GROUP mygroup myuser COUNT 10 BLOCK 10000 STREAMS mystream \> &
cl2pid=$!
redis-cli xreadgroup GROUP mygroup myuser COUNT 10 BLOCK 10000 STREAMS mystream \> &
cl3pid=$!

echo Clients PIDs: $cl1pid $cl2pid $cl3pid
sleep 0.5

echo Running triggering command
redis-cli xadd mystream MAXLEN 5000 '*' field1 value1 field2 value2 field3 value3 &
triggerpid=$!
sleep 1

echo Wait for at most 15 seconds
waitpid -t 15 $triggerpid
waitret=$?
echo Waitpid returned $waitret

if [ $waitret -eq 0 ] || [ $waitret -eq 1 ]; then
    echo [OK] Client not blocked, no bug
elif [ $waitret -eq 3 ]; then
    echo [BUG] Client blocked, bug detected
    pkill -11 redis-server
fi

kill $cl1pid $cl2pid $cl3pid $triggerpid
exit 0
