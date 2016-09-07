#!/bin/bash
# This is a wrapper script for stopping and starting AWS instances from EC2.
# This script is invoking a AWS Lambda fuction. Inorder to work, you have to
# create the Lambda function in AWS console and the EC2 from which this script
# is running should have 'aws cli' installed. This wrapper is written conidering
# there is a fixed list of instances to start or stop. 
#
# Refer : https://github.com/bijohnvincent/ScheduleStartStopEc2Lambda
# For details about setting up the Lambda function to stop and start instances.




#################   Variables to be modified by user  ######################
LambdaFunction="StartStopInstances"
# Leave LambdaVersion blank if you want to use the LATEST code in Lambda
LambdaVersion=""
Region="eu-west-1"
LambdaOutputFile="LambdaOuput.txt"
LambdaLogFile="startstop.log"
# Comma seperated InstanceList
# eg: InstanceList="NameOfInstance1, NameOfInstance2" 
InstanceList="DataNode1"
############################################################################

# Point to latest version of Lambda if no version is specified
if [ -z $LambdaVersion ]; then
	LambdaVersion="\$LATEST"
fi


## Function definition Usagehelp()
function usagehelp ()
{
	echo "Script usage help:"
	echo "$0 start"
	echo "$0 stop"
}



## Function definition start-stop()
function start-stop ()
{
	echo date >> $LambdaLogFile
	aws lambda invoke \
		--log-type Tail \
		--function-name "$LambdaFunction" \
		--region "$Region" \
		--payload '{"action": "'"$1"'","instances":"'"$InstanceList"'"}'\
		--qualifier "$LambdaVersion"\
		"$LambdaOutputFile" >> $LambdaLogFile
	echo "Status:"
	tail -4 $LambdaLogFile |grep LogResult|cut -d\" -f4|base64 --decode
}



## Main
case $1 in
start )
	echo "Starting ec2 instances" >> $LambdaLogFile
	start-stop start
	;;
stop )
	echo "Stopping ec2 instances" >> $LambdaLogFile
	start-stop stop
	;;
* )
	usagehelp
	exit 1;
	;;
esac
