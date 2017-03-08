for i in `cat zonehdpkerb.group| grep x` ; do  echo  "addgroup `echo $i | awk -F ':' '{print $1}'` --gid  `echo $i | awk -F ':' '{print $3}'`   ";done  
