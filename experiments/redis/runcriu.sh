#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

source /usr/share/modules/init/bash

MODE=criu

EXP=
CASE=
IDX=
SLEEP_TIME=120

cmdname=$0

function usage {
    code=${1:-0}

    echo "Usage: $cmdname <case> <idx> [-g|--expgroup=<name>] [-k|--killtime=120]
    Creates an output folder named result-<case>.
    --exp-group adds a -<name> suffix to the output folder."

    exit $code
}

function fail {
    echo "$1"
    exit 1
}

posargidx=0
while (( $# )); do
    case "$1" in
        -g=*|--expgroup=*)
            EXP="-${1#*=}";;
        -k=*|--killtime=*)
            SLEEP_TIME="${1#*=}";;
        -h|--help)
            usage;;
        *)
            case $posargidx in
            0)  CASE="$1";;
            1)  IDX="$1";;
            *)  usage 1;;
            esac
            posargidx=$((posargidx+1));;
    esac
    shift
done

if (( "$posargidx" != 2 )); then
    usage 1
fi

set -x

FOLDER="result-$CASE$EXP"

TRIGGER="trigger-$CASE.sh"
LOADLOG="$FOLDER/$MODE-$IDX-load.log"
SERVERLOG="$FOLDER/$MODE-$IDX-server.log"
TRIGGERLOG="$FOLDER/$MODE-$IDX-trigger.log"
WKLOG="$FOLDER/$MODE-$IDX-ycsb.log"
DUMPLOG="`pwd`/$FOLDER/$MODE-$IDX-dump.log"
RESTORELOG="`pwd`/$FOLDER/$MODE-$IDX-restore.log"

if ! [ -f "$TRIGGER" ]; then
	echo "Cannot find script $TRIGGER"
	exit 1
fi
case "$CASE" in
	(10070|12290|761) SYS=orig-72; CONF=nosave.conf;;
	(7445) SYS=orig-7445; CONF=nosave-7445.conf;;
	(*) echo "Unknown case $CASE" >&2; exit 1;;
esac

mkdir -p "$FOLDER" || fail "Cannot create folder $FOLDER"

set +x
module load ycsb || fail "Cannot load ycsb"
module load redis/"$SYS" || fail "Cannot load redis/$SYS"
module load criu || fail "Cannot load criu"
module list
command -v criu || fail "Command not found: criu"
command -v ycsb || fail "Command not found: ycsb"
command -v redis-server || fail "Command not found: redis-server"
set -x

CRIU=$(which criu)
RUNDATADIR="`pwd`/criurundata"
sudo rm -r "$RUNDATADIR/image"
sudo rm -r "$RUNDATADIR/image-tmp"
sudo mkdir -p "$RUNDATADIR/image"
sudo mkdir -p "$RUNDATADIR/image-tmp"

function dumpserver() {
	# note that child will exit even if tcp-close is not specified,
	# tcp-close is only to make criu work
	sudo $CRIU dump -j -t $1 -D $RUNDATADIR/image-tmp/ --leave-running \
		--tcp-close --skip-in-flight -vvv -o $DUMPLOG && \
	sudo rm -r "$RUNDATADIR/image" && \
	sudo mv "$RUNDATADIR/image-tmp" "$RUNDATADIR/image" && \
	sudo mkdir -p "$RUNDATADIR/image-tmp"
}

function checkpoint() {
	for i in `seq 2`; do
		sleep 30
		dumpserver $1
	done
}

function restoreserver {
	sudo time $CRIU restore -D $RUNDATADIR/image/ -j -d \
		--tcp-close -vvv -o $RESTORELOG \
	|| echo "$(tput bold)$(tput setaf 3)======= CRIU Restore Failed!!! ======$(tput sgr0)"
	echo "Restore finish time $(date +%s.%N)"
}

function runserver {
	mv dump.rdb dump.rdb.bak
	redis-server $CONF
	echo $?
	echo "Restore start time $(date +%s.%N)"
	restoreserver
	# redis-server $CONF is running when criu detached
}

(runserver 2>&1 | tee "$SERVERLOG") &
sleep 3
pid=`pgrep "redis-server"`

ycsb load redis -s -P param > "$LOADLOG" 2>&1
# echo 'SAVE' | redis-cli # echo 'BGSAVE' | redis-cli
dumpserver $pid
(sleep $SLEEP_TIME; ./"$TRIGGER" > "$TRIGGERLOG" 2>&1) &
checkpoint $pid &
ycsb run redis -s -P param > "$WKLOG" 2>&1

killall -9 redis-server
sleep 3
pgrep redis-server && echo "$(tput bold)$(tput setaf 3)redis-server not exited cleanly!$(tput sgr0)"
sudo chown $(id -u):$(id -g) $DUMPLOG
sudo chown $(id -u):$(id -g) $RESTORELOG
