# Windows Events to Cloud Watch Logs
This project was started to meet a need to have WorkSpaces Event Logs be recorded in CloudWatch for Audit and Admin purposes.

Features in the design of this release (and concepts) are as follows, anything not ticked is a concept for future releases
 - [x] Records PowerShell Logs for TroubleShooting
 - [ ] Writes to the Windows Event Viewer
 - [x] Uploads Windows Event Logs to Cloud Watch
 - [ ] Stores CloudWatch Credentials in Encrypted Format
 - [x] Configures and Restarts the CloudWatch Agent on Startup
 - [x] Creates a Unique ID for each WorkSpace
 - [ ] Maximum Log File Size Limits Defined

## Testing and Proof of Concept
The following environments have been considered, this has been tested with success in the ticked options
- [x] Amazon WorkSpaces PCoIP Windows Server 2016 Base Image
- [ ] Amazon WorkSpaces PCoIP Windows Server 2019 Base Image
- [x] AWS SimpleAD Directory Service
- [ ] AWS Managed Active Directory
- [ ] Active Directory Connect and/or Cognito

## Known Issues
The following issues are either known or considered with this current release, see issue tab for more issues (tick as resolved)
- [ ] PowerShell ability to write to the Server 2016 Event Log is limited and often fails causing errors
- [ ] IAM Permissions for the Cloud Watch Agent account are Potential Over Privileged and need to be reviewed/limited
- [ ] Storage of Credentials are not Encrypted, Suggest using NTFS/ACL's to limit access

# Setup and Provisioning of Service
This solution is driven by Active Directory Group Policy and needs to be configured from a Domain Admin.

For details on how to gain access to AWS SimpleAD or Managed AD Group Policy see the follow documentation,
https://docs.aws.amazon.com/workspaces/latest/adminguide/group_policy.html

You will need the Cloud Watch Agent MSI to be installed, this can be sourced from here,
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance.html

The following is required to complete this solution,
 - The Cloud Watch Agent needs to be pre-installed or installed via Group Policy
 - The included CloudFormation Stack for IAM and Log Groups needs to be applied
 - The PowerShell file needs to be run AS Admin from Group Policy

## AWS Authentication and Log Groups
TO COMPLETE!!

### Batch Process CLI Authentication
TO LINK TO AWS DOCUMENTATION

## Modifying the PowerShell Script
Information here will be updated in the near future, some options are currently unavailable

TO COMPLETE!!

### Using Encrypted Credentials
TO COMPLETE!! ADD A PS1 SOLUTION TO MAIN

## Installation of the Cloud Watch Agent
The Cloud Watch Agent can be installed in 2 different ways for this solution,
 - Include the Cloud Watch Agent in the Base Image with a Custom Bundle
 - Deploy the Cloud Watch Agent from a File Server via Group Policy
 
 I would recommend using Group Policy so that the MSI can be replaced with newer versions over time,

 At the time of writing this the Cloud Watch x64 Agent is at Version 1.3 but by using Group Policy you can force an upgrade to v1.4 without internet access.

 To setup in Group Policy you can deploy an Assigned Application under Computer Configuration
  - Computer Configuration > Policies > Software Settings > Software Installation > Right Click > New > Package...

This will install the Cloud Watch Agent on System Start Up, you can start the WorkSpace via the AWS Console and the user does not need to logon for this to apply.

Noting that you may need to boot the WorkSpace more than once so that the policy can update and then install the application at a later startup.

## Configuring via Group Policy
The configuration script (.\main\logagent.ps1) can be run via Group Policy by adding this to a file server (network share) and setup in Group Policy here,
 - Computer Configuration > Policies > Windows Settings > Scripts > Startup > PowerShell Scripts (Tab)
 - Because of the Cloud Watch Installation Restriction you need to run as admin, Use the Parameter "-Verb RunAs" and the GPO will run this with elevated privilege
 - Warning! Sometimes the PCoIP solution can cause a Black Screen of Death if UAC is enabled (Do your own Testing), I have not had this issue with WSP

This will run the PowerShell Script on System Start Up, you can start the WorkSpace via the AWS Console and the user does not need to logon for this to run.

Noting that you may need to boot the WorkSpace more than once so that the policy can update and then run the script at a later startup.

# Disclaimer
This solution has been developed and tested in my own personal environment and works as designed.

However, this solution comes with zero assurance and zero warranty, users need to review this solution before using it.

I do not accept any responsibility for negative impacts of this solution, the user should have an understanding of both AWS and PowerShell to a level high enough to understand any risks and take full responsibility of the use of this solution upon their selves!

This is a concept and a demo, not a download and run solution!  .
This solution has been written with Visual Studio Code on Windows 10 x64 Professional.

I hope you find this solution helpful and I welcome your polite constructive feedback.