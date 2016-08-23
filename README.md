# cmapi_clusterstartstop
Start or stop Cloudera Manager, CDH and daemons via CM API

##Introduction
This script lets you start and (gracefully) stop a Cloudera Hadoop cluster. The highlights are:
 - Uses CM API(python client) for managing CDH and CM services, so will support all Cloudera versions till date(<CDH 5.7.1)
 - Uses Ansbile 'service' module for managing Linux daemons(cloudera-scm-[agent,server,server-db]), so is portable across all Linux versions.
 - Central management script(which is the only file that a user needs to modify) is written in bash.

##Typical use cases
 - Can be used to automate shutdown and start of Hadoop cluster during off peak hours. Most cloud providers bill VMs per hour, so you can have considerable savings on monthly bill by coupling this script to the inbuilt VM shutdown/start utility. For example, in AWS you can link this to Lambda and shutdown clusters between 22:00 to 6:00 daily and reduce the monthly bill by 1/3.
 - Quickly stop/start multiple Cloudera Hadoop clusters during maintenance(Eg: Datacenter power maintenance).

##Pre-requisites
 - A working Cloudera Hadoop cluster
 - Install the following packages in the node where you execute the script
   * ansible  (http://docs.ansible.com/ansible/intro_installation.html#installing-the-control-machine)
   * cm-api python client  (https://cloudera.github.io/cm_api/docs/python-client/#installation)

##List of Scripts
 - startstopcluster.sh
 - python/stopcmservices.py
 - python/startcmservices.py
 - python/stopcdhservices.py
 - python/startcdhservices.py

##Usage
 - Open script file 'startstopcluster.sh' and edit parameters as per your environment'
 - Execute the script:
```sh
./startstopcluster.sh start
./startstopcluster.sh stop
```

