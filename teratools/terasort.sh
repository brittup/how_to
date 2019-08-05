# terasort.sh
# Kill any running MapReduce jobs
mapred job -list | grep job_ | awk ' { system("mapred job -kill " $1) } '
# Delete the output directory
hadoop fs -rm -r -f -skipTrash /benchmarks/terasort/terasort-output
# Run terasort
time hadoop jar \
/opt/cloudera/parcels/CDH/jars/hadoop-mapreduce-examples-2.6.0-cdh5.16.2.jar \
terasort \
-Ddfs.blocksize=512M \
-Dio.file.buffer.size=131072 \
-Dmapreduce.map.java.opts=-Xmx1536m \
-Dmapreduce.map.memory.mb=2048 \
-Dmapreduce.map.output.compress=true \
-Dmapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.Lz4Codec \
-Dmapreduce.reduce.java.opts=-Xmx1536m \
-Dmapreduce.reduce.memory.mb=2048 \
-Dmapreduce.task.io.sort.factor=100 \
-Dmapreduce.task.io.sort.mb=768 \
-Dyarn.app.mapreduce.am.resource.mb=1024 \
-Dmapred.reduce.tasks=100 \
-Dmapreduce.terasort.output.replication=1 \
/benchmarks/terasort/terasort-input \
/benchmarks/terasort/terasort-output
