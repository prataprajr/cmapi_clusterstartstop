#!/usr/bin/env python
#Author: Pratap Raj
#Purpose: Start CDH

import sys
import socket
from cm_api.api_client import *
from cm_api.endpoints.cms import ClouderaManager

#########
# Do not edit any system variables here. They are all passed from the startcluster.sh script, so make changes there.
cmhost=str(sys.argv[1])
cmport=str(sys.argv[2])
cmusername=str(sys.argv[3])
cmpassword=str(sys.argv[4])
tlspref=str(sys.argv[5])
clustername=str(sys.argv[6])
#########

api = ApiResource(cmhost, server_port=cmport, username=cmusername, password=cmpassword, use_tls=tlspref)

cdhstartstatus=api.get_cluster(clustername).start().wait()
print cdhstartstatus.success
