#!/bin/bash

#adduser anonymous --home  /home/anonymous  --shell  /bin/bash  --uid 3031   --gid 3031 --gecos hadoop-svc-account  
for i in `cat zonehdpkerb.passwd| grep x` ; do  echo  "adduser `echo $i | awk -F ':' '{print $1}'` --home  `echo $i | awk -F ':' '{print $6}'`  --shell  `echo $i | awk -F ':' '{print $7}'`  --uid `echo $i | awk -F ':' '{print $3}'`  --gid `echo $i | awk -F ':' '{print $4}'` -c `echo $i | awk -F ':' '{print $5}'`  ";done  
