#!/usr/bin/env python3

import re
import sys
from statistics import mean, stdev


vals = []

for line in sys.stdin:
    a=re.search(r'READ: Count=(.+?),', line.strip())
    if not a:
        continue
    vals.append(int(a.group(1)))


def dprint(*args, **kwargs):
    """Debug print"""
    print(*args, file=sys.stderr, **kwargs)


def find_drop(values):
    drop_start = None
    for i in range(len(values) - 1):
        if values[i] > 10 * values[i+1]:
            drop_start = i+1
            dprint(f'Drop start {i+1}s')
            dprint(f'Before drop {values[i]} after {values[i+1]}')
            break
    else:
        dprint('Drop not found, suppose 121s')
        drop_start = 120

    stable_perf = None
    for i in range(3):
        sub = values[drop_start-i-5:drop_start-i]
        if stdev(sub) * 10 < mean(sub):
            stable_perf = mean(sub)
            stable_time = drop_start-i-5
            dprint(f'Stable range start {drop_start-i-5}s')
            dprint(f'Range is {sub} mean {stable_perf}')
            break
    else:
        dprint('Performance not stable {values[drop_start-3-5:drop_start]}!')
        os.exit(1)

    for i in range(drop_start, len(values)):
        if values[i] > 2 * values[drop_start]:
            fifth_perf = values[i+5-1]/stable_perf*100
            downtime = i - stable_time
            dprint(f'Guessing restarted time {i}, perf[i-5:i+5] {values[i-5:i+5]}')
            dprint(f'    5s perf is {values[i+5-1]}/{stable_perf} = {fifth_perf}%')
            break
    else:
        dprint(f'Seems cannot find restarted time, suppose 120s')
        i = 120
        fifth_perf = values[i+5-1]/stable_perf*100
        downtime = i - stable_time
        dprint(f'Guessing restarted time {i}, perf[i-5:i+5] {values[i-5:i+5]}')
        dprint(f'    5s perf is {values[i+5-1]}/{stable_perf} = {values[i+5-1]/stable_perf*100}%')

    thres = 0.9
    for i in range(drop_start, len(values)):
        if values[i] >= thres * stable_perf:
            ninety_time = i - drop_start
            dprint(f'{thres*100}% perf after {ninety_time}s, at {i}-th sec')
            break
    else:
        max_value = max(values[drop_start:])
        max_index = values[drop_start:].index(max_value)
        max_percent = max_value / stable_perf
        ninety_time = max_index
        dprint(f'Cannot find {thres*100}% perf point, max {max_percent*100}%')
        dprint(f'    Max after {max_index}s, at {max_index+drop_start}-th sec')

    # structured output for script
    print(f"FINDDROP: {downtime} {fifth_perf} {ninety_time}")

find_drop(vals)
