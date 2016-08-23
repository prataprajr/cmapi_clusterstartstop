#!/bin/bash
#Author: Pratap Raj
#Purpose: Start CDH, Cloudera Manager and all cloudera daemons

#########
# User configurable variables starts here. Edit these values to suit your cloudera manager details

#_cmhost is the Ip address of your Cloudera Manager server. Eg: 10.10.0.230
_cmhost="127.0.0.1"

#_cmport is the port of Cloudera Manager webui. For TLS use 7183, for nonTLS use 7180
_cmport="7183"

#_cmusername is the username to your Cloudera Manager web UI, with administrator role enabled.
_cmusername="admin"

#_cmpassword is the password of your Cloudera admin user
_cmpassword=''

#_cmtlspref can be True or False, depending on the availability of TLS for Cloudera Manager web ui
_cmtlspref="True"

#_clustername has a default value of 'cluster'. In case its not working you can call API method get_all_clusters() to get exact cluster name.
#Ref: https://cloudera.github.io/cm_api/epydoc/5.7.0/cm_api.api_client.ApiResource-class.html#get_all_clusters
_clustername="cluster"

#_ansibleusername is the sudo user for running ansible ad hoc commands
_ansibleusername="hadoopadmin"

#_entirecluster is the name in ansible hosts file(/etc/ansible/hosts) that maps to all hosts in the Hadoop cluster
_entirecluster="cluster"

# User configurable variables end here. Do NOT edit anything below this line.
########

function usagehelp {
 echo "Script usage help:"
 echo "$0 start"
 echo "$0 stop"
}

function daemoncontrol {
 #Proceed with Cloudera daemon start
 echo "$1ing Cloudera daemons"
 ansible "$_cmhost" -u"$_ansibleusername" --become -m service -a "name=cloudera-scm-server-db state=$1ed"
 ansible "$_cmhost" -u"$_ansibleusername" --become -m service -a "name=cloudera-scm-server state=$1ed"
 ansible "$_entirecluster" -u"$_ansibleusername" --become -m service -a "name=cloudera-scm-agent state=$1ed"
}

function startcluster {
 echo "This script will start CDH, Cloudera Manager and all cloudera daemons. Do you want to proceed? [no]/yes"
 read _pref
 if [ "$_pref" != "yes" ]; then
   echo "Exiting on user cancel"
   exit 1;
 fi

 # Start daemons
 daemoncontrol start
echo "Waiting 1 minute for Cloudera Manager server to come up.."
sleep 1m

 # Start Cloudera Management services
 echo "Starting Cloudera Management services. This may take a few minutes.."
 _cmstartstatus=$(python python/startcmservices.py "$_cmhost" "$_cmport" "$_cmusername" "$_cmpassword" "$_cmtlspref")
 if [ "$_cmstartstatus" = "True" ]; then
  echo "Successfully started Cloudera Management services"
 else
  echo "Looks like Cloudera management services are already running. Check cloudera-scm-server logs if it is not the case"
 fi

 # Start CDH services 
 echo "Starting CDH services. Please wait, this may take several minutes.."
 _cdhstartstatus=$(python python/startcdhservices.py "$_cmhost" "$_cmport" "$_cmusername" "$_cmpassword" "$_cmtlspref" "$_clustername")
 if [ "$_cdhstartstatus" = "True" ];then
  echo "Successfully started CDH services"
  else 
  echo "Looks like CDH is already running. Check cloudera-scm-server logs if it is not the case"
 fi

}

function stopcluster {
 echo "This script will shutdown CDH, Cloudera Manager and all cloudera daemons. Do you want to proceed? [no]/yes"
 read _pref
 if [ "$_pref" != "yes" ]; then
  echo "Exiting on user cancel"
  exit 1;
 fi

 # Proceed with shutdown of CDH services
 echo "Shutting down CDH. Please wait, this may take several minutes.."
 _cdhstopstatus=$(python python/stopcdhservices.py "$_cmhost" "$_cmport" "$_cmusername" "$_cmpassword" "$_cmtlspref" "$_clustername")
 if [ "$_cdhstopstatus" = "True" ];then
  echo "Successfully stopped CDH services"
  else
  echo "An error has occured during CDH stop. Please check cloudera-scm-server logs"
  exit 1
 fi

 # Proceed with shutdown of Cloudera Management services
 echo "Stopping Cloudera Management services. This may take a few minutes.."
 _cmstopstatus=$(python python/stopcmservices.py "$_cmhost" "$_cmport" "$_cmusername" "$_cmpassword" "$_cmtlspref")
 if [ "$_cmstopstatus" = "True" ]; then
  echo "Successfully stopped Cloudera Management services"
  else
  echo "An error has occured during Cloudera management service stop. Please check cloudera-scm-server logs"
  exit 1
 fi

 #Stop daemons. Spelling of stop is intentionally set to 'stopp'. Reason: Compatibility with ansible service module
 daemoncontrol stopp
}
 
#_scriptaction=$1
#Validate number of arguments
#if [ $# -ne 1 ];then
# usagehelp
# exit 1;
#fi

case $1 in
start )
startcluster
;;
stop )
stopcluster
;;
* )
usagehelp
;;
esac


