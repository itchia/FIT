<#
.Synopsis
This script is to create a virtual machine in azure resource manager.

.Description
This script is to create a virtual machine in azure resource manager by taking only mandatory input parameter as Virtual Machine name(vmname).
If none other parameters are provided script will create two resource group one to place virtual machine, storage account & VM's public ip and
other resource group to place network.

.Example
create-yourvminrm -vmname "myfirstvm"

This will create a virtual machine "myfirstvm", a storage account "stamyfirstvm" with an IP address 10.100.32.10.
If you want to create a virtual machine in existing resource group or in existing vnet, type the IP address correctly.

.Example
Create-yourvminrm -vmname "myfirstvm" -resourceGroupName "myresourcegrp"

This will create a virtual machine "myfirstvm" either in an existing resource group "myresourcegrp" or create the same resource group.
All other parameter will taken default.

.Example
Create-yourvminrm -vmname "myfirstvm" -vnetname "myvnet" -vnetresourcegroup "vnetrg" -Location "Southeast Asia" -ipaddress "10.100.32.11"
With this script it will create a vm with IP address 10.100.32.11. If you creating a VM in an existing subnet please make sure you
assign correct IP address

.Example
Create-yourvminrm -vmname "azure-ava-scom" -resourceGroupName "RG-Ava-SC" -vnetname "azure-avanade-lab-vNet-01" -vnetresourcegroup "rg-ava-vnets" -Location "Southeast Asia" -ipaddress "10.100.32.30" -storageaccname "storagetoscom" -vmsize Standard_A2 -ErrorLog
If you mention vnet name then valid IP address must need to be mention to create the VM

.Example
Create-yourvminrm -vmname "myfirstvm" -vnetaddress "192.100.0.0/16" -subnetaddress "192.168.32.0/19" -ipaddress "192.168.32.10" -ErrorLog
If specifying vNet address then it must to specify subnet address and IP address. Else script will fail as it will take default address from
10.100.x.x/19 subnet.

Author: Manash Maitra (manashmaitra@gmail.com)
#>
function Create-yourvminrm {
    
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True,
                   ValueFromPipeline = $True)]
        [string]$vmname,
        [String]$resourceGroupName = "rg-$vmname",
        [String]$vnetname = "vNet-$vmname",
        [String]$vnetaddress = "10.100.0.0/16",
        [String]$subnetaddress = "10.100.32.0/19",
        [String]$vnetresourcegroup = "rg-$vnetname",
        [validateset("Southeast Asia","Australia East","Australia Southeast",
                     "East Asia","South Central US","Central US")]
        [String]$Location = "Southeast Asia",
        [String]$ipaddress = "10.100.32.10",
        [String]$storageaccname = "sta$vmname",
        [validateset("Standard_A1","Standard_A2","Standard_A3","Standard_A4","Standard_A5","Standard_A6","Standard_A7")]
        [String]$vmsize = "Standard_A2",

        [Switch]$ErrorLog,
        [String]$LogFile = "C:\errorlog.txt"
     )
     
     Begin{
          if($ErrorLog){ Write-Verbose 'Error logging turn on'} Else { Write-Verbose 'Error logging turn off'}
          Write-Verbose "vmname $vmname"
     }

     Process{
     
             ## Resource Group Validation
             $vmrg = (Get-AzureRmResourceGroup -Name $resourceGroupName -Location $Location `
                                               -ErrorAction SilentlyContinue -ErrorVariable ev1).ResourceGroupName
             If($vmrg -eq $null){Write-Output "Resource Group doesn't exist in subscription. Creating the resource group $resourceGroupName"
             New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location -Tag @{name=$resourceGroupName}}
             Else {Write-Output "Resource Group exist in the subscription"}

             ## Storage Account Validation
             $sta = (Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageaccname `
                                              -ErrorAction SilentlyContinue -ErrorVariable ev2).StorageAccountName
             If($sta -eq $null){Write-Output "Storage Account doesn't exist in subscription. Creating storage account $storageaccname"
             New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageaccname -Type Standard_LRS -Location $Location}
             Else{Write-Output "Storage Account exist"}

             ## Virtual Network Validation
             $vnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $vnetresourcegroup -Name $vnetname `
                                                -ErrorAction SilentlyContinue -ErrorVariable ev3).Name
             If($vnet -eq $null){Write-Output "Virtual Network doesn't exist in the subscription. Creating the vNet $vnetname"
             New-AzureRmResourceGroup -Name $vnetresourcegroup -Location $Location -Tag @{Name="rg-vnet"}
             $sb1 = New-AzureRmVirtualNetworkSubnetConfig -Name "Subnet-1" -AddressPrefix $subnetaddress
             New-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $vnetresourcegroup -Location $Location `
                                       -AddressPrefix $vnetaddress -Subnet $sb1 -Tag @{Name="vnet tag"}}
             Else{Write-Output "vNet exist in the subscription"}

             ## Starting  to create the Virtual Machines
               
             ## Creating Public IP and Nic card for VM
             Write-Output "Creating public ip address for VM ....."
             $pip = New-AzureRmPublicIpAddress -Name "pip$vmname" -ResourceGroupName $resourceGroupName -Location $Location -AllocationMethod Dynamic
             $sbid = ((Get-AzureRmVirtualNetwork -ResourceGroupName $vnetresourcegroup -Name $vnetname).Subnets).id | Select-Object -First 1
             $ncard = New-AzureRmNetworkInterface -Name "nc$vmname" -ResourceGroupName $resourceGroupName -Location $Location `
                                                  -SubnetId $sbid -PrivateIpAddress $ipaddress -PublicIpAddressId $pip.Id
             
             ## Creating vmconfig file
             $vmc = New-AzureRmVMConfig -VMName $vmname -VMSize $vmsize
             $vmc = Set-AzureRmVMOperatingSystem -VM $vmc -Windows -ComputerName $vmname `
                                                 -Credential (Get-Credential -Message "Please type the local admin credential of the VM")
             $vmc = Set-AzureRmVMSourceImage -VM $vmc -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" `
                                             -Skus "2012-R2-Datacenter" -Version "latest"
             ## Attaching nic card to VM
             $vmc = Add-AzureRmVMNetworkInterface -VM $vmc -Id $ncard.Id
             
             ## Creating OS disk for the VM
             Write-Output "Creating OS disk for VM"
             $sta = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageaccname
             $disk = "disk1$vmname"
             $diskurl = $sta.PrimaryEndpoints.Blob.ToString() + "vhds/" + $disk + ".vhd"
             $vmc = Set-AzureRmVMOSDisk -VM $vmc -Name $disk -VhdUri $diskurl -CreateOption fromImage

             ## Let create the VM
             Write-Output "Creating the VM ...."
             New-AzureRmVM -ResourceGroupName $resourceGroupName -VM $vmc -Location $Location -verbose

             Write-Output "VM $vmname has been created"
      }

      End{}

}
                                                                      