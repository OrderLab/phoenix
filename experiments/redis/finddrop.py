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

def find_drop(values):
    drop_start = None
    for i in range(len(values) - 1):
        if values[i] > 10 * values[i+1]:
            drop_start = i+1
            print(f'Drop start {i+1}s')
            print(f'Before drop {values[i]} after {values[i+1]}')
            break
    else:
        print('Drop not found, suppose 121s')
        drop_start = 120

    stable_perf = None
    for i in range(3):
        sub = values[drop_start-i-5:drop_start-i]
        if stdev(sub) * 10 < mean(sub):
            stable_perf = mean(sub)
            print(f'Stable range start {drop_start-i-5}s')
            print(f'Range is {sub} mean {stable_perf}')
            break
    else:
        print('Performance not stable {vlaues[drop_start-3-5:drop_start]}')
        return

    for i in range(drop_start, len(values)):
        if values[i] > 2 * values[drop_start]:
            print(f'Guessing restarted time {i}, perf[i-5:i+5] {values[i-5:i+5]}')
            print(f'    5s perf is {values[i+5-1]}/{stable_perf} = {values[i+5-1]/stable_perf*100}%')
            break
    else:
        print(f'Seems cannot find restarted time, suppose 120s')
        i = 120
        print(f'Guessing restarted time {i}, perf[i-5:i+5] {values[i-5:i+5]}')
        print(f'    5s perf is {values[i+5-1]}/{stable_perf} = {values[i+5-1]/stable_perf*100}%')

    thres = 0.9
    for i in range(drop_start, len(values)):
        if values[i] >= thres * stable_perf:
            print('{}% perf after {}s, at {}-th sec'.format(thres*100, i - drop_start, i))
            break
    else:
        max_value = max(values[drop_start:])
        max_index = values[drop_start:].index(max_value)
        max_percent = max_value / stable_perf

        print(f'Cannot find {thres*100}% perf point, max {max_percent*100}%')
        print(f'    Max after {max_index}s, at {max_index+drop_start}-th sec')
        return

find_drop(vals)
