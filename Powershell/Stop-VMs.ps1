<#
    .SYNOPSIS 
    Stops all the Azure VMs in a specific Azure Resource Group

    .DESCRIPTION
    This simple runbook stops all of the virtual machines in the specified Azure Resource Group.
    It is particularly useful for CSP (Cloud Solution Provider) customers, or users who have multiple subscriptions, as both Tenant ID and Subscription ID can 
    be specified.

    Note: Edit the $CredentialAssetName to match your Automation Credential Asset name.
    The account should have VM Contributor rights on the Resource Group you are targeting, or the ability to perform the “stop” VM action.
    More info on creating custom RBAC roles can be found here: 
    https://azure.microsoft.com/en-us/documentation/articles/role-based-access-control-configure/#custom-roles-in-azure-rbac

    .PARAMETER ResourceGroupName
    Required
    Name of the Azure Resource Group containing the VMs to be stopped.

    .PARAMETER TenantID
    Required
    Tenant ID of the Azure account you are targeting (use Get-AzureRMSubscription to view). This should be provided in 
    the format xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx

    .PARAMETER SubscriptionID
    Required
    Subscription ID of the Azure subscription that the Resource Group resides in (use Get-AzureRMSubscription to view). 
    This should be provided in the format xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx

    .PARAMETER CredentialAssetName
    Required
    The name of the credential asset used to connect to the resource group. This must have at least Virtual Machine Contributor permissions.

    .REQUIREMENTS 
    This runbook makes use of the Azure Resource Manager PowerShell global module (now included
    in Azure Automation)

    .NOTES
    This runbook was originally created to power off Virtual Machines overnight and at weekends to prevent charging for 
    resources that are not needed 24x7, it is also ideal for Dev / Test labs. 
    It can easily be adapted to start Virtual Machines too by replacing Stop-AzureRMVM with Start-AzureRMVM. 
    The powering off of VMs works in parallel, but if you require certain machines to be powered off first before the workflow 
    begins, add them before the ForEach loop.

    AUTHOR: Jay Avent 
    LASTEDIT: March 30, 2016

#>

workflow Stop-VMs
{
	Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $ResourceGroupName,
		[Parameter(Mandatory=$true)]
        [String]
		$TenantID,
		[Parameter(Mandatory=$true)]
        [String]
		$SubscriptionID,
		[Parameter(Mandatory=$true)]
        [String]
		$CredentialAssetName
    )

	#Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName;
    if(!$Cred) {
        Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    }

    #Connect to your Azure Account
	Login-AzureRmAccount -Credential $Cred -TenantId $TenantID;
	
    #Connect to subscription
    Select-AzureRmSubscription -SubscriptionId $SubscriptionID  -TenantId $TenantID

	$vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName;
	
	Foreach -Parallel ($vm in $vms){
			Write-Output "Stopping $($vm.Name)";		
			Stop-AzureRmVm -Name $vm.Name -ResourceGroupName $ResourceGroupName -Force;
			}
}