# teragen.sh

# Kill any running MapReduce jobs
mapred job -list | grep job_ | awk ' { system("mapred job -kill " $1) } '
# Delete the output directory

hadoop fs -rm -r -f -skipTrash /benchmarks/terasort/terasort-input 
# Run teragen
time hadoop jar \
/opt/cloudera/parcels/CDH/jars/hadoop-mapreduce-examples-2.6.0-cdh5.16.2.jar \
teragen \
-Ddfs.blocksize=512M \
-Dio.file.buffer.size=131072 \
-Dmapreduce.map.java.opts=-Xmx1536m \
-Dmapreduce.map.memory.mb=2048 \
-Dmapreduce.task.io.sort.mb=256 \
-Dyarn.app.mapreduce.am.resource.mb=1024 \
-Dmapred.map.tasks=64 \
10000000000  \
/benchmarks/terasort/terasort-input
