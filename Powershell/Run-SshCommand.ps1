<#
.SYNOPSIS
  This runbook provides an example of how to run a command on a Linux machine from Azure Automation. 
  The command parameter defaults to 'sudo apt-get update ; sudo apt-get -y upgrade' to retrieve and install of the available updates on the machine.  
  NOTE: if you have many updates upgrade may run for a while. 

.DESCRIPTION
  This runbook provides an example of how to run a command on a Linux machine. 

  REQUIRED AUTOMATION ASSETS  

  1. SSH PowerShell module: 
     http://www.powershellgallery.com/packages/SSH/1.0.0 or search "SSH" by JoeLevy on the Automation Module Gallery 
  2. An Automation connection asset containing the connection information needed to remote to your Linux machine

.PARAMETER Command
    Optional
   The command to run on the Linux machine.  This defaults to 'apt-get update / apt-get upgrade' to retrieves and install 
   updates to your Linux machine.  

.PARAMETER ConnectionName
   Mandatory
   The name of the Automation connection asset that contains the connection object to connect with a Linux machine.

.NOTES
   LASTEDIT: March 23, 2016
#>


Param (
    [Parameter(Mandatory=$false)] 
	[string] $Command = "sudo apt-get update ; sudo apt-get -y upgrade",

    [Parameter(Mandatory=$true)] 
    [string] $ConnectionName
)

$Conn = Get-AutomationConnection -Name $ConnectionName
$CommandScriptBlock = [scriptblock]::Create($Command)

Invoke-SSHCommand `
		-Connection $Conn `
		-ScriptBlock $CommandScriptBlock


