<#
.SYNOPSIS
    Adjust size of Azure VM

.DESCRIPTION
   This script will adjust the size of a Microsoft Azure virtual machine based on input.
   
   This Runbook use globalw assets defined in the Azure Automation Account. 
   For more information about how to create assets please check our this article:
   http://azure.microsoft.com/blog/2014/07/29/getting-started-with-azure-automation-automation-assets-2/
   
   WARNING: For this runbook to work, you must have created the 
   following Assets: Powershell Credentials for a Co-Administator account. 
   
   This script is based on this Microsoft Technet article: 
   http://msdn.microsoft.com/en-us/library/dn168976(v=nav.70).aspx
   
.PARAMETER AzureSubscriptionName
     String name of the Azure Subscription that hosts the virtual machine that will have the size changed.

.PARAMETER AzureOrgIdCredential
     String name of the PSCredential stored in global assets for authentication against the
     Microsoft Azure Serive Management API (Azure Ressource Manager)

.PARAMETER VirtualMachineName
    String that contains the name of the virtual machine that will be sized
                 
.PARAMETER CloudServiceName
    String name of the cloud service containing the virtual machine. 
 
.PARAMETER VirtualMachineSize
    String size of the virtual machine. 
    Se sizes here: http://msdn.microsoft.com/en-us/library/azure/dn197896.aspx
 
Allowed 'RoleSize'values:
aSmall,Small,Medium,Large,ExtraLarge,A5,A6,A7,A8,A9,Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4,Standard_D1,Standard_D2
,Standard_D3,Standard_D4,Standard_D11,Standard_D12,Standard_D13,Standard_D14'.
 
.NOTES
	Author: Peter Selch Dahl from ProActive A/S
	Last Updated: 12/22/2014
    Version 1.0   
#>


workflow Adjust_Size_of_Azure_VM
{
    
        Param
    (            
        [parameter(Mandatory=$true)]
        [String]
        $AzureSubscriptionName = 'FIT Enterprise Azure',

        [parameter(Mandatory=$true)]
        [PSCredential]
        $AzureOrgIdCredential,
        
        [parameter(Mandatory=$true)]
        [String]
        $VirtualMachineSize = 'Medium',
         
        [parameter(Mandatory=$true)]
        [String]
        $CloudServiceName = 'FITLABS',
                 
        [parameter(Mandatory=$true)]
        [String]
        $VirtualMachineName = 'FITLABSvm1'      
    )



    
    $throwawayOutput = Add-AzureAccount -Credential $AzureOrgIdCredential

	# Select the Azure subscription we will be working against
    $throwawayOutput = Select-AzureSubscription -SubscriptionName $AzureSubscriptionName

   Write-Output "-------------------------------------------------------------------------"
   Write-Output "     Get Azure Account"
   Write-Output "-------------------------------------------------------------------------"
   Get-AzureAccount
   Write-Output " " 
 
   Write-Output "-------------------------------------------------------------------------"
   Write-Output "     Get Azure Subscription"
   Write-Output "-------------------------------------------------------------------------"
   Get-AzureSubscription
   Write-Output "-------------------------------------------------------------------------"
   Write-Output " "

   Write-Output "-------------------------------------------------------------------------"
   Write-Output "Get Azure Virtual Machines"    
   Write-Output "-------------------------------------------------------------------------"
         
   $vm = Get-AzureVM            
   Write-Output $vm

   Write-Output "-------------------------------------------------------------------------"
   Write-Output " "



    InlineScript { 

   Get-AzureVM –ServiceName $Using:CloudServiceName –Name $Using:VirtualMachineName | Set-AzureVMSize $Using:VirtualMachineSize | Update-AzureVM
    
    }

}


