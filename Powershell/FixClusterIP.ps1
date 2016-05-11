# This script should be run on the primary cluster node after the internal load balancer is created
# Define variables

$ClusterNetworkName = "Cluster Network 1" # the cluster network name

$IPResourceName = "SQL IP Address 1 (sqlcluster)" # the IP Address resource name

$ClusterIP = "10.0.0.30" # IP address of your SQL CLuster resource and ILB

Import-Module FailoverClusters

# If you are using Windows 2012 or higher, use the Get-Cluster Resource command. If you are using Windows 2008 R2, use the cluster res command which is commented out.

Get-ClusterResource $IPResourceName | Set-ClusterParameter -Multiple @{"Address"="$ClusterIP";"ProbePort"="59999";SubnetMask="255.255.255.255";"Network"="$ClusterNetworkName";"OverrideAddressMatch"=1;"EnableDhcp"=0}

# cluster res $IPResourceName /priv enabledhcp=0 overrideaddressmatch=1 address=$CloudServiceIP probeport=59999  subnetmask=255.255.255.255
WARNING: The properties were stored, but not all changes will take effect until SQL IP Address 1 (sqlcluster)