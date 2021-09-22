# Windows Events to Cloud Watch Logs
This project was started to meet a need to have WorkSpaces Event Logs be recorded in CloudWatch for Audit and Admin purposes.

Features in the design of this release (and concepts) are as follows, anything not ticked in a provisioned option for future releases
 - [x] Records PowerShell Logs for TroubleShooting
 - [ ] Writes to the Windows Event Viewer
 - [x] Uploads Windows Event Logs to Cloud Watch
 - [ ] Stores CloudWatch Credentials in Encrypted Format
 - [x] Configures and Restarts the CloudWatch Agent on Startup
 - [x] Creates a Unique ID for each WorkSpace

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
- [ ] IAM Permissions for the Cloud Watch Agent account are excessive and need to be reviewed/limited
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


### MORE DOCUMENTAION TO COME - SIMPLE USE GUIDE AND ADDITIONAL INFORMATION