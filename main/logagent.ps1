<#
    .SYNOPSIS
        Configuires the CloudWatch Agent on Local WorkSpace
    .DESCRIPTION
        Amazon CloudWatch Agent is installed via Group Policy and then this script runs following.
        Script takes the Default configuration from a Network share and copies to the local system and configures it
        Can also takes the encrypted credentials from NetLogon, decrypts them uses them for authentication
        Finally this starts the CloudWatch Agent and sees logs sent to CloudWatch
    .NOTES
        THIS SCRIPT MUST BE RUN AS ADMIN (Use '-Verb RunAs')
        Author        :   https://github.com/GrumpyBum
        Peer Review   :   https://www.linkedin.com/in/dineshsharma2511/
        Last Update   :   22nd September 2021
        Environment   :   GitHub Demo Script Only
        Documentation :   https://github.com/GrumpyBum/winevents2cloudwatch#readme
#>

$localFolder = 'C:\CloudWatchConfig'
$localConfig = 'C:\CloudWatchConfig\config.json'  ## Change Warning! Read Documentation First
$localAuthority = 'C:\CloudWatchConfig\credentials'  ## Change Warning! Read Documentation First
$sourceConfig = '\\fileserver\cloudwatch\config.json'
$sourceAuthority = '\\fileserver\cloudwatch\credentials'
$programData = 'C:\ProgramData\Amazon\AmazonCloudWatchAgent\common-config.toml'
$scriptLogs = 'C:\logs'

function CloudWatchFolder {
    New-Item -Path $localFolder -ItemType 'Directory'

    # Insert 'Set-Acl' here to restrict NTFS Permissions (Requirement 2)
    # Is this Required? Domain Users DO NOT have access to NTFS on File

    Copy-Item $sourceConfig $localConfig
    (Get-Content $localConfig) -replace '(?<="log_stream_name":")[^"]*', ($env:COMPUTERNAME) | Set-Content $localConfig

    # Copy-Item $sourceAuthority C:\CloudWatchConfig\credentials
}

function CloudWatchConfig {
    Copy-Item $sourceConfig $localConfig -Verbose
    (Get-Content $localConfig) -replace '(?<="log_stream_name":")[^"]*', ($env:COMPUTERNAME) | Set-Content $localConfig
}

function CloudWatchCredential {
    if (Get-Item $localAuthority) {
        Remove-Item $localAuthority
    }

    $strData = ConvertTo-SecureString -String (Get-Content $sourceAuthority)[0]
    $dataPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($strData)
    $strFinal = [Runtime.InteropServices.Marshal]::PtrToStringAuto($dataPtr)
    Add-Content -Path $localAuthority -Value $strFinal

    $strData = ConvertTo-SecureString -String (Get-Content $sourceAuthority)[1]
    $dataPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($strData)
    $strFinal = [Runtime.InteropServices.Marshal]::PtrToStringAuto($dataPtr)
    $strOutput = 'aws_access_key_id = ' + $strFinal
    Add-Content -Path $localAuthority -Value $strOutput

    $strData = ConvertTo-SecureString -String (Get-Content $sourceAuthority)[2]
    $dataPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($strData)
    $strFinal = [Runtime.InteropServices.Marshal]::PtrToStringAuto($dataPtr)
    $strOutput = 'aws_secret_access_key = ' + $strFinal
    Add-Content -Path $localAuthority -Value $strOutput

    Add-Content -Path $localAuthority -Value 'region = ap-southeast-2'
}

function CloudWatchToml {
    Move-Item $programData C:\ProgramData\Amazon\AmazonCloudWatchAgent\common-config-old.toml -Verbose
    Add-Content -Path $programData -Value '[credentials]'
    Add-Content -Path $programData -Value '   shared_credential_profile = "AmazonCloudWatchAgent"'
    Add-Content -Path $programData -Value '   shared_credential_file = "C:\\CloudWatchConfig\\credentials"'
}

function StartCloudWatchAgent {
    Write-EventLog -EventId 2021 -LogName System -Message "Starting CloudWatch Agent" -Source "Group Policy Scripts" -Category 1409 -ComputerName $env:COMPUTERNAME -EntryType Information
    Write-Host "Entering Cloud Watch Log Initiator"
    Set-Location "C:\Program Files\Amazon\AmazonCloudWatchAgent"
    try {
        .\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m onPremise -c file:'C:\CloudWatchConfig\config.json' -s
        Write-Host 'Cloud Watch Agent Started, Logs will appear in Cloud Watch within 20min'
    }
    catch {
        Write-Host 'Cloud Watch Agent Failed to Start, Please Contact Support'
    }
}

# Script Test and Action
Add-Content -Path C:\logs\posh-cwagent-update-times.log -Value (Get-Date) # Confirming RunTime in UTC (SimpleAD Domain Controler Time)
Add-Content -Path C:\logs\posh-cwagent-update-times.log -Value 'Tesing Object 01' # This needs to be MUTED as for Test/Dev Only

if (!(Get-Item -Path $scriptLogs -ErrorAction SilentlyContinue)) {
    New-Item -Path $scriptLogs -ItemType 'Directory'
} elseif (Get-Item -Path C:\logs\posh-cwagent-gp.log -ErrorAction SilentlyContinue) {
    if (Get-Item -Path C:\logs\posh-cwagent-gp.old) {
        Remove-Item C:\logs\posh-cwagent-gp.old
    }
    Move-Item C:\logs\posh-cwagent-gp.log C:\logs\posh-cwagent-gp.old
}

Start-Transcript C:\logs\posh-cwagent-gp.log

$startScript = "Starting Group Policy PowerShell Script for Amazon Cloud Watch Installation and Configuration"
Write-Host $startScript
try {
    Write-EventLog -EventId 2021 -LogName System -Message $startScript -Source "Group Policy Scripts" -Category 1409 -ComputerName $env:COMPUTERNAME -EntryType Information    
} catch {
    New-EventLog -LogName System -Message "New System Event Creation" -Source "Group Policy Scripts" -ComputerName $env:COMPUTERNAME -Verbose
    Write-EventLog -EventId 2021 -LogName System -Message $startScript -Source "Group Policy Scripts" -Category 1409 -ComputerName $env:COMPUTERNAME -EntryType Information
    Write-Host 'EventLog Creation Run'
}

# CloudWatchCredential #Updates the Credentials File
# TO ADD? - Change ACL on credentials file to restrict user access
if ($localAuthority) {
    Remove-Item $localAuthority
    Copy-Item $sourceAuthority $localAuthority
    Write-Host 'Local Authority Replaced'
} else {
    Copy-Item $sourceAuthority $localAuthority
    Write-Host 'Local Authority Created'
}

if (!(Get-Item -Path $localFolder -ErrorAction SilentlyContinue)) {
    Write-EventLog -EventId 2021 -LogName System -Message "Initiating CloudWatch Folder Configuration" -Source "Group Policy Scripts" -Category 1409 -ComputerName $env:COMPUTERNAME -EntryType Information
    CloudWatchFolder
}
if (!(Get-Item -Path $localConfig -ErrorAction SilentlyContinue)) {
    CloudWatchConfig
}

if (!(Get-Item -Path C:\ProgramData\Amazon\AmazonCloudWatchAgent\common-config-old.toml -ErrorAction SilentlyContinue)) {
    Write-EventLog -EventId 2021 -LogName System -Message "Initiating CloudWatch Agent Instruction" -Source "Group Policy Scripts" -Category 1409 -ComputerName $env:COMPUTERNAME -EntryType Information
    CloudWatchToml
}

if (Get-Process amazon-cloudwatch-agent -ErrorAction SilentlyContinue) {
    Stop-Process -Id (Get-Process amazon-cloudwatch-agent).Id -Force -Verbose
}
StartCloudWatchAgent

Stop-Transcript