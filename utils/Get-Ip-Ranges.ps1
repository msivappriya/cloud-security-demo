<#
.SYNOPSIS
    Retrieves and displays AWS IP ranges for a specified region and service.

.DESCRIPTION
    This script downloads the AWS IP ranges JSON file (if it doesn't already exist)
    and filters it to extract and display the IPv4 and IPv6 address ranges
    for a given AWS service in a specified AWS region.

.PARAMETER Region
    Specifies the AWS region to filter IP ranges for. Defaults to "us-east-1".

.PARAMETER Service
    Specifies the AWS service to filter IP ranges for. Defaults to "EC2_INSTANCE_CONNECT".

.EXAMPLE
    .\Get-AWSIpRanges.ps1 -Region "us-west-2" -Service "S3"

    Downloads or uses an existing ip-ranges.json file, then displays IPv4 and IPv6 ranges for
    S3 in the us-west-2 region.

.EXAMPLE
    .\Get-AWSIpRanges.ps1

    Downloads or uses an existing ip-ranges.json file, then displays IPv4 and IPv6 ranges for
    EC2 Instance Connect in the us-east-1 region.

.NOTES
    Requires PowerShell 5.1 or later.
    The script downloads the ip-ranges.json file from AWS if it is not found in the same directory.
    The script will exit with an error code of -1 if the download of the json file fails.
    The script will display an error message if the processing of the json file fails.
    AWS IP ranges are subject to change. It is recommended to run this script periodically.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$Region = "us-east-1",

    [Parameter(Mandatory = $false)]
    [string]$Service = "EC2_INSTANCE_CONNECT"
)

$url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
$jsonFilePath = "ip-ranges.json"

if (Test-Path -Path $jsonFilePath) {
    Write-Host "JSON file already exists. Using existing file."
} else {
    try {
        Invoke-WebRequest -Uri $url -OutFile $jsonFilePath -ErrorAction Stop
        Write-Host "JSON file downloaded successfully."
    } catch {
        Write-Error "Error downloading the JSON file: $($_.Exception.Message)"
        return -1
    }
}

try {
    $ipRanges = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

    # IPv4 prefixes
    $ipv4Prefixes = $ipRanges.prefixes | Where-Object { $_.region -eq $Region -and $_.service -eq $Service }
    $ipv4Ranges = $ipv4Prefixes | Select-Object -ExpandProperty ip_prefix

    # IPv6 prefixes
    $ipv6Prefixes = $ipRanges.ipv6_prefixes | Where-Object { $_.region -eq $Region -and $_.service -eq $Service }
    $ipv6Ranges = $ipv6Prefixes | Select-Object -ExpandProperty ipv6_prefix

    # Output the IP ranges
    Write-Host "IPv4 Ranges for $Region and $Service :"
    $ipv4Ranges | ForEach-Object { Write-Host $_ }

    Write-Host "`nIPv6 Ranges for $Region and $Service :"
    $ipv6Ranges | ForEach-Object { Write-Host $_ }

} catch {
    Write-Error "Error processing the JSON file: $($_.Exception.Message)"
}
