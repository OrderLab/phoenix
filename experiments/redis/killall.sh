killall -9 redis-server
killall -9 redis-cli
killall -9 ycsb
ps aux | grep redis | awk '{print $2}' | xargs sudo kill -9
pgrep redis
pgrep ycsb
