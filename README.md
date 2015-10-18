# HelloWorld


## Description
This script is use to build a HA load-balanced website in AWS using cloudformation.

## Prerequisite
- aws cli.
- jp pkg installed on your machine.
- key pair for instances:pre setup in your asw account with name helloworld or change the key name in cft/asg.json.  

## How the script works ?
**security groups setup**
* It will setup two sercurity groups for ELB and Instances if it's not exsting using cloudformation.
* For instances: it allows inbound traffic on port 80 and 443 from ELB only and ssh 22 open from anywhere for troubleshooting.
* For ELB: it allows inbould traffic on port 80 and 444 from anywhere.

**Upload data to S3**
* It will upload the firstrun script and config files in app directory to S3

**Upload certification for ELB**
* It will upload the certification to iam if it's not exsting

**Create the autoscalling group stack**
* It will create a cloudformation stack with AutoScaleGroup,LaunchConfig and ElasticLoadBalancer.
* In the userdate, it will download the Date from S3 and run the firstrun.sh script to setup the instacnes.

**Validate if the website is up running**
* It will get the ELB DNS recorde from output of the  autoscaling group cloudformation stack and curl the ELB address.

##usage
./install.sh \<aws_profile\> \<vpcid\> \<releaseNO\>

## To Do List 
* Add instance role in the stack to access s3 buket
* Add frond end ELB and revproxy layers for cache and security purpose. 
* Add auto scaling up/down based on cloudwatch alerts
* If I have a domain, add DNS stack to switch DNS between releases.
* Manange the config files via Puppet
* Put this script into CI/CD tool like bamboo

##Example Output
**./install.sh myaws vpc-6428e701 2**

Checking if securitygroup stack exists...

++Creating sgstack stack...

{
    "StackId": "arn:aws:cloudformation:ap-southeast-2:602147953304:stack/sgstack/4c11ebe0-7529-11e5-8505-5081ed982a6e"
}

Waiting sgstack to be ready...
Waiting sgstack to be ready...
Waiting sgstack to be ready...

upload firstrun files to s3

make_bucket: s3://helloworld220151018104358/

upload: ./app.tar to s3://helloworld220151018104358/app.tar

Checking if cert for ELB exists...

helloworld certs already exists

Checking if stack exists...

++Creating helloworld2 stack...

{
    "StackId": "arn:aws:cloudformation:ap-southeast-2:602147953304:stack/helloworld2/87109cf0-7529-11e5-a1ce-50ba2bf5a2a6"
}

Waiting asgstack to be ready...
Waiting asgstack to be ready...
Waiting asgstack to be ready...
Waiting asgstack to be ready...
Waiting asgstack to be ready...

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    35  100    35    0     0   1166      0 --:--:-- --:--:-- --:--:--  1206

helloworl-ElasticL-WJP8MD5W8I1T-339834726.ap-southeast-2.elb.amazonaws.com is up








