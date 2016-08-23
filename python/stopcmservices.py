#!/usr/bin/env python
#Author: Pratap Raj
#Purpose: Stop Cloudera Management services

import socket
import sys
from cm_api.api_client import ApiResource
from cm_api.endpoints.cms import ClouderaManager

#########
# Do not edit any system variables here. They are all passed from the stopcluster.sh script, so make changes there.
cmhost=str(sys.argv[1])
cmport=str(sys.argv[2])
cmusername=str(sys.argv[3])
cmpassword=str(sys.argv[4])
tlspref=str(sys.argv[5])
#########

api = ApiResource(cmhost, server_port=cmport, username=cmusername, password=cmpassword, use_tls=tlspref)
mgmt=api.get_cloudera_manager().get_service()
cmstopstatus=mgmt.stop().wait()
print cmstopstatus.success
