# Author Peter Selch Dahl from ProActive A/S
# Revised by Anders Huusom from ProActive A/S
# Version 1.2

#import Azure Powershell

If (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}


 Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\azure\azure.psd1"

 function Install-MSIFile {

[CmdletBinding()]
 Param(
  [parameter(mandatory=$true,ValueFromPipeline=$true,ValueFromPipelinebyPropertyName=$true)]
        [ValidateNotNullorEmpty()]
        [string]$msiFile,

        [parameter()]
        [ValidateNotNullorEmpty()]
        [string]$targetDir
 )
if (!(Test-Path $msiFile)){
    throw "Path to the MSI File $($msiFile) is invalid. Please supply a valid MSI file"
}
$arguments = @(
    "/i"
    "`"$msiFile`""
    "/qn"
    "/norestart"
)
if ($targetDir){
    if (!(Test-Path $targetDir)){
        throw "Path to the Installation Directory $($targetDir) is invalid. Please supply a valid installation directory"
    }
    $arguments += "INSTALLDIR=`"$targetDir`""
}
Write-Verbose "Installing $msiFile....."
$process = Start-Process -FilePath msiexec.exe -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -eq 0){
    Write-Verbose "$msiFile has been successfully installed"
}
else {
    Write-Verbose "installer exit code  $($process.ExitCode) for file  $($msifile)"
}
}


#write installed Azure PoSh module version
 Write-Host ""
 Write-host "Checking Azure Powershell Version.."
 Write-Host ""
 Write-Host "Your Installed Azure Powershell Version is: " -NoNewline; Write-Host -ForegroundColor "Yellow" (Get-Module -Name azure).version.tostring()
 
 
 $CurrentInstalledAzurePowershellVersion = (Get-Module -Name azure).version.tostring()
 
#code block to check online version
 $web=(Invoke-Webrequest -Uri "http://github.com/Azure/azure-powershell/releases" -MaximumRedirection 1).links | where {$_.outertext -like "Windows Standalone"}
 
 $NewAzurePowershellVersion = ($web[0].href.Split("/")[($web[0].href.split("/")).length-1].trim("azure-powershell.").trim(".msi"))
 
 Write-Host "Lastest version online is: " -NoNewline;Write-Host -ForegroundColor "Yellow" ($web[0].href.Split("/")[($web[0].href.split("/")).length-1].trim("azure-powershell.").trim(".msi"))
 Write-Host ""

 if ($NewAzurePowershellVersion -ne $CurrentInstalledAzurePowershellVersion) 
 {


  Write-Host "MSI Direct Download Link: " -NoNewline;Write-Host -ForegroundColor Yellow $web[0].href
  Write-Host "Reference: https://github.com/Azure/azure-powershell/releases"
  Write-Host ""

  $source = $web[0].href
  $destination =  $Env:temp + "\" + ($web[0].href.Split("/")[($web[0].href.split("/")).length-1])
  
  Write-Host "Downloading MSI File....."
  Write-Host ""

  Invoke-WebRequest $source -OutFile $destination

  $destination| Install-MSIFile -Verbose

 }
