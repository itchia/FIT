function Get-RMUsageAggregates {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [DateTime]$reportedStartTime,

        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [DateTime]$reportedEndTime,
        
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$resourceGroup,

        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$subscriptionId,

        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$granularity
        
    )
    PROCESS {

        
        Select-AzureRMSubscription -SubscriptionId $subscriptionId

        # Set usage parameters

        $showDetails = $true

        # Export Usage to CSV

        $appendFile = $false

        $continuationToken = ""

        Add-Type -AssemblyName System.Web

        Do { 

            $usageData = Get-UsageAggregates `
                -ReportedStartTime $reportedStartTime `
                -ReportedEndTime $reportedEndTime `
                -AggregationGranularity $granularity `
                -ShowDetails:$showDetails `
                -ContinuationToken $continuationToken

            Write-Output [-InputObject $usageData.UsageAggregations.Properties | 
                Where-Object {$_.InstanceData -like "*resourceGroups/$resourceGroup*"} |
                Select-Object `
                    UsageStartTime, `
                    UsageEndTime, `
                    @{n='SubscriptionId';e={$subscriptionId}}, `
                    MeterCategory, `
                    MeterId, `
                    MeterName, `
                    MeterSubCategory, `
                    MeterRegion, `
                    Unit, `
                    Quantity, `
                    @{n='Project';e={$_.InfoFields.Project}}, `
                    InstanceData

            if ($usageData.NextLink) {

                $continuationToken = `
                    [System.Web.HttpUtility]::UrlDecode($usageData.NextLink.Split("=")[-1])

            } else {

                $continuationToken = ""

            }

            $appendFile = $true

        } until (!$continuationToken)
    }
}