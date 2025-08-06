# Experiment

We provide scripts for the following list of experiments mentioned in the paper.

## Recovery Time (Figure 9)

For each system and each recovery mechanism, `cd` into each system's folder,
run `./run<mechanism>.sh`, with case number, and the round of run. For example,
to run Redis case 761 using Builtin for 5 times, run the following command in
`redis` folder:

```bash
for i in {1..5}; do ./runbuiltin.sh 761 $i; done
```

This will generate a `result-761` results folder, containing `builtin-1-*` log files.
