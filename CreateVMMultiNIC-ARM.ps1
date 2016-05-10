##Script Parameters##

$RGName = <ResourceGroup Name>;
$Location = <Azure Location>;
$VNetName = <VNet Name>;
$SubnetName01 = <Subnet Name>;
$SubnetName02 = <Subnet Name>;
$StorageAccountName = <Storage Account>;
$VMSize = <Azure VM Type>;
$Publisher = <Publisher>;
$Offer = <Offer>;
$SKU = <SKU>;
$OSVersion = <OS Version>;
$VMName = <VM Name>;
$NicNamePrefix = <NIC Name Prefix>;

#Main Script
#Get VNet & Subnet Details
$VNet = Get-AzureRmVirtualNetwork -Name:$VNetName -ResourceGroupName:$RGName;
$Subnet1 = $VNet.Subnets|?{$_.Name -eq $SubnetName01};
$Subnet2 = $VNet.Subnets|?{$_.Name -eq $SubnetName02};

#Get Storage Account
$StorageAccount = Get-AzureRmStorageAccount -Name:$StorageAccountName -ResourceGroupName:$RGName;

#Create Network Interfaces
#Create NIC #1
$nic1Name = $NicNamePrefix + "-01";
$Nic1 = New-AzureRmNetworkInterface -Name:$nic1Name -ResourceGroupName:$RGName -Location:$Location -SubnetId:$Subnet1.Id;

#Create NIC #2
$nic2Name = $nicNamePrefix + "-02";
$nic2 = New-AzureRmNetworkInterface -Name:$nic2Name -ResourceGroupName:$RGName -Location:$Location -SubnetId:$Subnet2.Id;

#Create Azure VM Config
$vmConfig = New-AzureRmVMConfig -VMName:$VMName -VMSize:$VMSize;

#Set Admin Account and OS Type
$Credential = Get-Credential -Message "Type the name and password for local administrator account.";
$vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName:$VMName -Credential:$Credential;

#Set Azure Image
$vmConfig = Set-AzureRmVMSourceImage -VM:$vmConfig -PublisherName:$Publisher -Offer:$Offer -Skus:$SKU -Version:$OSVersion;

#Set Primary Azure NIC
$vmConfig = Add-AzureRmVMNetworkInterface -VM:$vmConfig -Id:$nic1.Id -Primary;
$vmConfig = Add-AzureRmVMNetworkInterface -VM:$vmConfig -Id:$nic2.Id;

$osDiskName = $VMName + "-OS"
$osVhdUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $osDiskName + ".vhd";
$vmConfig = Set-AzureRmVMOSDisk -VM:$vmConfig -Name:$osDiskName -VhdUri:$osVhdUri -CreateOption:fromImage;

#Create AzureVM
New-AzureRmVM -VM:$vmConfig -ResourceGroupName:$RGName -Location:$Location;