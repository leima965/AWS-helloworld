# helloworld


## Description
This script is use to build a HA load-balanced website in AWS using cloudformation.

## Prerequisite
- aws cli.
- jp pkg installed on your machine.
- key pair for instances 
<hr>
## How the script works ?
**security groups setup**
*It will setup two sercurity groups for ELB and Instances if it's not exsting using cloudformation.
*For instances: it allows inbound traffic on port 80 and 443 from ELB only and ssh 22 open from anywhere for troubleshooting.
*For ELB: it allows inbould traffic on port 80 and 444 from anywhere. <br />

**Upload data to S3**
* It will upload the firstrun script and config files in app directory to S3<br />

**Upload certification for ELB**
* It will upload the certification to iam if it's not exsting<br />

**create the autoscalling group stack**
*It will create a cloudformation stack with AutoScaleGroup,LaunchConfig and ElasticLoadBalancer.<br />
*In the userdate, it will download the Date from S3 and run the firstrun.sh script to setup the instacnes.<br />

**validate the website is up running**
*It will get the ELB DNS recorde from output of the  autoscaling group cloudformation stack and curl the ELB address. <br />
<hr>




