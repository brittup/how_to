﻿https://docs.cloudera.com/HDPDocuments/Ambari-2.7.5.0/bk_ambari-installation/content/ch_Getting_Ready.html



yum -y install bind-utils wget ntp
systemctl enable ntpd
****************************************************************************
##Ambari  Preparation
****************************************************************************

ssh-keygen
ssh-copy-id root@X.X.X.X
cat /root/.ssh/id_rsa  --- > copy to txt file for ambari install

systemctl disable firewalld
service firewalld stop

vi /etc/selinux/config 
SELINUX=disabled

reboot

sestatus






####Install Ambari
###wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.1.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
###wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.3.0/ambari.repo -O /etc/yum.repos.d/ambari.repo


wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.4.0/ambari.repo -O /etc/yum.repos.d/ambari.repo 


yum repolist
yum -y install ambari-server


ambari-server setup

ambari-server start
ambari-server status



###install mysql connector
###https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.1.0/bk_ambari-installation/content/download_and_set_up_database_connectors.html
###https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.3.0/bk_ambari-installation/content/download_and_set_up_database_connectors.html  

https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.4.0/bk_ambari-installation/content/download_and_set_up_database_connectors.html  

yum -y install mysql-connector-java*

ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar 

ambari-server restart



###Install Isilon Mgmt Pack for Ambari
Install Ambari Management Pack


####
Download the Ambari Management Pack for Isilon OneFS installation bundle from the product download page and extract the contents on to the Ambari server

or copy to host 


####wget https://github.com/brittup/how_to/raw/master/hadoop/2.7/isilon-onefs-mpack-1.0.1.0.tar.gz
####wget https://github.com/brittup/how_to/raw/master/hadoop/2.7/isilon-onefs-mpack-1.0.2.0.tar.gz


wget https://github.com/brittup/how_to/raw/master/hadoop/2.7/isilon-onefs-mpack-1.0.3.0.tar.gz

Install the management pack on the Ambari server by running the following command: 
###ambari-server install-mpack --mpack=NAME_OF_MPACK_TAR.tar.gz –verbose 
###ambari-server install-mpack --mpack=isilon-onefs-mpack-1.0.1.0.tar.gz --verbose
###ambari-server install-mpack --mpack=isilon-onefs-mpack-1.0.2.0.tar.gz --verbose



ambari-server install-mpack --mpack=isilon-onefs-mpack-1.0.3.0.tar.gz --verbose

ambari-server restart
ambari-server status



###continue with install_setup


###isilon setup:     https://github.com/brittup/how_to/blob/master/hadoop/2.7/isilon_setup.txt

or

go to linux host  -- setup linux for isilon users uid/gid

All hosts
yum -y install krb5-workstation krb5-libs openldap-clients



###Do not continue unless Isilon and Linux user/group/base directory setup is complete




###Build HDP Cluster

Go to ambari server host:8080
http://10.246.156.6:8080


Follow the Ambari & Hortonworks Installation Isilon Guide  Page21
https://dl.dell.com/content/docu90562_PowerScale_OneFS_with_Hadoop_and_Hortonworks_Installation_Guide.pdf?language=en_US&source=Coveo   




use the OneFS tab to set the smartconnect zone name
isi hdfs settings modify --zone=zone_name --ambari-metrics-collector=<FQDN_of_HDP client_running_Ambari_metrics_collector_service>
