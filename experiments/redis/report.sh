#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

if ! [ -d "$1" ]; then
	echo "Usage: $0 <result_folder>"
fi

folder="$1"

phxdownscript='
/^FAULT:/ {
	found_fault = 1
	fault_time = $2/1000000
}
/^NEWREQ:/ {
	if (found_fault) { newreq_time = $2/1000000 }
}
/^Restore finish time/ {
	print $0
	if (found_fault) { newreq_time = $4 }
}
END {
	if (found_fault) { print "SERVERDOWN:", newreq_time-fault_time }
}'

awkscript='
BEGIN { count=0; phx_count=0; found_fault=0 }
/^FINDDROP:/ {
	sum_downtime += $2
	sum_5th += $3
	sum_90time += $4
	count += 1
}
/^SERVERDOWN:/ {
	sum_downtime_server += $2
	phx_count += 1
}
END {
	if (count==0) {
		print "    N/A         N/A           N/A          N/A"
		exit
	}
	if (phx_count && phx_count != count) {
		printf "Error: phx server log count %d != total run count %d\n", phx_count, count
		exit 1
	}
	
	if (phx_count) { sum_downtime = sum_downtime_server }

	avg_down = sum_downtime/count
	avg_5th = sum_5th/count
	avg_90time = sum_90time/count - avg_down
	if (avg_90time < 0) avg_90time = 1

	printf "%6d  % 12.2f % 12.3f%% % 12.1f\n", count, avg_down, avg_5th, avg_90time
}'

echo -e "Mode      Runs  Downtime (s)  5-sec Avail.  90% Time (s)"
for mode in vanilla builtin criu phx; do
	echo -ne "$mode\t"
	(
	for f in "$folder/"$mode-*-server.log; do
		[ -f "$f" ] && awk "$phxdownscript" "$f"
	done
	for f in "$folder/"$mode-*-ycsb.log; do
		if [ -f "$f" ]; then
			criuflag=
			if [ "$mode" = criu ]; then
				criuflag='--min-start=100'
			fi
			./finddrop.py $criuflag < "$f" 2>/dev/null || (echo "Find drop failed on $f!"; ./finddrop.py < "$f")
		fi
	done
	) | awk "$awkscript"
done
