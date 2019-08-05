# teravalidate.sh
# Kill any running MapReduce jobs
mapred job -list | grep job_ | awk ' { system("mapred job -kill " $1) } '
# Delete the output directory
hadoop fs -rm -r -f -skipTrash /benchmarks/terasort/teravalidate-output 
# Run teravalidate
time hadoop jar \
/opt/cloudera/parcels/CDH/jars/hadoop-mapreduce-examples-2.6.0-cdh5.16.2.jar \
teravalidate \
-Ddfs.blocksize=512M \
-Dio.file.buffer.size=131072 \
-Dmapreduce.map.java.opts=-Xmx1536m \
-Dmapreduce.map.memory.mb=2048 \
-Dmapreduce.reduce.java.opts=-Xmx1536m \
-Dmapreduce.reduce.memory.mb=2048 \
-Dmapreduce.task.io.sort.mb=256 \
-Dyarn.app.mapreduce.am.resource.mb=1024 \
-Dmapred.reduce.tasks=1 \
/benchmarks/terasort/terasort-output \
/benchmarks/terasort/teravalidate-output
