# Experiment

We provide scripts for the following list of experiments mentioned in the paper.

## Recovery Time (Figure 9)

For each system and each recovery mechanism, `cd` into each system's folder,
run `./run<mechanism>.sh`, with case number, and the round of run.  Supported
mechanisms are `vanilla`, `builtin`, `phx`, and `criu`.

For example, to run Redis case 761 using Builtin for 5 times, run the following
command in `redis` folder:

```bash
for i in {1..5}; do ./runbuiltin.sh 761 $i; done
```

This will generate a `result-761` results folder, containing `builtin-1-*` log
files.

To generate report for one case, run `report.sh` with the folder name:

```bash
./report.sh result-761/
```

This will generate a table of report as below (running for 3 times). This
corresponds to the raw data in Appendix C, and Figure 9.

```text
Mode      Runs  Downtime (s)  5-sec Avail.  90% Time (s)
vanilla	     3          0.80        3.209%       1649.9
builtin	     3         53.04       86.988%        177.6
criu	     3          7.26       95.832%          1.0
phx	     3          0.08      104.259%          1.0
```

### Cleanup

In case of an unclean exit of experiment, the started applications may be still
running in the background.  Run `killall.sh` to force exit all experiment
processes.
