#! /bin/bash
#set -x
if [ $# -ne 3 ]; then
        echo ""
        echo "Usage: ./install.sh <aws_profile> <vpcid> <releaseNO> "
        echo ""
        echo ""
        exit 1
fi
profile=$1
vpcid=$2
release=$3
sgstackname="sgstack"
product="helloworld"
asgstackname=$product$release

ddate=`date +%Y%m%d%H%M%S`
# Check if sg stack exists
        echo ""
        echo "Checking if securitygroup stack exists..."
        aws --profile $profile cloudformation describe-stacks | grep $sgstackname > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo ""
                echo "$sgstackname stack already exists"
        else
                echo "++Creating $sgstackname stack..."
                aws --profile $profile cloudformation create-stack --stack-name $sgstackname --template-body file://cft/sg.json --parameters ParameterKey=VpcId,ParameterValue=${vpcid}
                echo ""
                n=0
                m=0
                while [ $n -eq 0 ]; do
                n=`aws --profile $profile cloudformation describe-stacks --stack-name $sgstackname | grep -c CREATE_COMPLETE`
                echo "Waiting $sgstackname to be ready..."
                sleep 30
                let m=$m+30
                if [ $m -ge 300 ]; then
                        echo "Error: timed out, the status is: `aws cloudformation describe-stacks --stack-name $sgstackname| jq '.Stacks[] .StackStatus'`"
                        echo ""
                        exit 1
                fi
                done

        fi


SGELBID=`aws --profile $profile cloudformation describe-stacks --stack-name $sgstackname|jq -r '.Stacks[] .Outputs[] | select(.OutputKey=="SGELBID")' | jq -r .OutputValue`
SGWEBID=`aws --profile $profile cloudformation describe-stacks --stack-name $sgstackname|jq -r '.Stacks[] .Outputs[] | select(.OutputKey=="SGWEBID")' | jq -r .OutputValue`
subnet=`aws --profile $profile ec2 describe-subnets |grep SubnetId |cut -d \" -f4 |sed 'N;s/\n/,/'`
SUBNET=`echo [${subnet}]`

function create_asgstack {
# Check if asg stack exists
      echo ""
        echo "Checking if stack exists..."
        aws --profile $profile cloudformation describe-stacks | grep $asgstackname > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo ""
                echo "$asgstackname stack already exists"
        else
                echo "++Creating $asgstackname stack..."
                

                aws --profile $profile cloudformation create-stack --stack-name $asgstackname --template-body file://cft/asg.json --parameters ParameterKey=SGELB,ParameterValue=${SGELBID} ParameterKey=SGWEB,ParameterValue=${SGWEBID} ParameterKey=Subnet,ParameterValue=$SUBNET ParameterKey=Product,ParameterValue=${asgstackname}  ParameterKey=S3URL,ParameterValue=${s3url} ParameterKey=CertARN,ParameterValue=${ARN} ParameterKey=Release,ParameterValue=${release}
                echo ""
                n=0
                m=0
                while [ $n -eq 0 ]; do
                n=`aws --profile $profile cloudformation describe-stacks --stack-name $asgstackname | grep -c CREATE_COMPLETE`
                echo "Waiting $asgstackname to be ready..."
                sleep 30
                let m=$m+30
                if [ $m -ge 300 ]; then
                        echo "Error: timed out, the status is: `aws cloudformation describe-stacks --stack-name $sgstackname| jq '.Stacks[] .StackStatus'`"
                        echo ""
                        exit 1
                fi
                done

        fi
}

tar cf app.tar app
echo ""
echo "upload firstrun files to s3"
aws --profile $profile s3 mb s3://$asgstackname$ddate 
aws --profile $profile s3 cp app.tar s3://$asgstackname$ddate  --grants full=uri=http://acs.amazonaws.com/groups/global/AllUsers
s3url=`echo https://s3-ap-southeast-2.amazonaws.com/$asgstackname$ddate/app.tar`

# Check if certs exists
      echo ""
        echo "Checking if cert for ELB exists..."
        aws --profile $profile iam get-server-certificate --server-certificate-name $product > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo ""
                echo "$product certs already exists"
        else
                echo "++Creating $product certs..."
                
                aws --profile $profile iam upload-server-certificate --server-certificate-name $product --certificate-body file://app/files/helloworldpublic.pem --private-key file://app/files/helloworldkey.pem

        fi
ARN=`aws --profile $profile iam get-server-certificate --server-certificate-name $product |grep Arn|cut -d \" -f4`

create_asgstack

ELBDNS=`aws --profile $profile cloudformation describe-stacks --stack-name $asgstackname|jq -r '.Stacks[] .Outputs[] | select(.OutputKey=="ELBDNSNAME")' | jq -r .OutputValue`
echo ""
echo "pause the script for 4mins to wait for the DNS ready"
sleep 4m


weboutput=`curl -k https://$ELBDNS`
if [[ $weboutput ==  *"Hello World"* ]]
then
   echo " $ELBDNS is up "
else
   echo " something is wroing with $asgstack web please log to the box and check"
   exit
fi
