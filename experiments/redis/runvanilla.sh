#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <expgroup> <case> <idx> [killtime]"
	exit 1
fi

set -x

EXP=${1}
CASE=${2}
IDX=${3}
SLEEP_TIME=${4:-120}

FOLDER="result-vanilla-$EXP"

mkdir -p "$FOLDER"

TRIGGER="trigger-$CASE.sh"
LOADLOG="$FOLDER/$CASE-$IDX-load.log"
SERVERLOG="$FOLDER/$CASE-$IDX-server.log"
TRIGGERLOG="$FOLDER/$CASE-$IDX-trigger.log"
WKLOG="$FOLDER/$CASE-$IDX.log"

if ! [ -f "$TRIGGER" ]; then
	echo "Cannot find repro script"
	exit 1
fi
case "$CASE" in
	(10070|12290|761) SYS=orig-72; CONF=nosave.conf;;
	(7445) SYS=orig-7445; CONF=nosave-7445.conf;;
	(*) echo "Unknown case $CASE" >&2; exit 1;;
esac

set +x
module load ycsb || exit 1
module load redis/"$SYS" || exit 1
module list
set -x

function runserver {
	mv dump.rdb dump.rdb.bak
	redis-server $CONF
	echo $?
	date +%s
	redis-server $CONF
}

(runserver > "$SERVERLOG") &
sleep 3
pid=$!

ycsb load redis -s -P param_vanilla > "$LOADLOG" 2>&1
# echo 'SAVE' | redis-cli # echo 'BGSAVE' | redis-cli
(sleep $SLEEP_TIME; ./"$TRIGGER" > "$TRIGGERLOG" 2>&1) &
ycsb run redis -s -P param_vanilla > "$WKLOG" 2>&1

killall -9 redis-server
sleep 3
pgrep redis-server && exit 1
