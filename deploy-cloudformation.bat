@ECHO OFF 

ECHO Documentation Available at https://github.com/GrumpyBum/winevents2cloudwatch#readme

if "%1"=="" goto bad

:good

@ECHO OFF
ECHO .
ECHO This batch file will deploy a CFN Stack to create the CloudWatch Agent IAM User Account and CloudWatch Log Groups

ECHO .
@ECHO ON

set /P c=Do you want to Create(C) the User or Update(U) the user and groups? [C/U/X]?
if /I "%c%" EQU "P" goto :create-user
if /I "%c%" EQU "D" goto :update-user
if /I "%c%" EQU "X" goto :almost-end

:create-user
@ECHO OFF
ECHO  Creating IAM Roles and CloudWatch stack named git-workspaces-events
aws cloudformation create-stack --profile %1 --stack-name git-workspaces-events --capabilities CAPABILITY_NAMED_IAM --template-body file://main/loggroups.yaml --parameters file://main/iamtags.json
ECHO CFN Stack has been Created
goto :almost-end

:update-user
ECHO  Updating IAM Roles and CloudWatch stack named git-workspaces-events
aws cloudformation create-change-set --profile %1 --stack-name git-workspaces-events --capabilities CAPABILITY_NAMED_IAM --template-body file://main/loggroups.yaml --parameters file://main/iamtags.json
ECHO CFN Stack Change Set has been Created - Please go to the Console to review and approve Change in the git-workspaces-events Stack
goto :almost-end

:almost-end
@ECHO OFF
ECHO Have a Nice Day :)
goto :end

:bad
@ECHO OFF
ECHO .
ECHO Please Use a Profile name passed as a parameter to this script

:end
ECHO .
ECHO End of Process. 