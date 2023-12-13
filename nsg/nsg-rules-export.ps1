# Name of Resource Group
$resourceGroupName = Read-Host -Prompt "Enter the name of the Resource Group"
# $resourceGroupName = "[Resource Group Name]"

# Name of Network Security Group
$nsgName = Read-Host -Prompt "Enter the name of the Network Security Group"
# $nsgName = "[Network Security Group Name]"

#------------------------------------------------------------------------------------------------------------------------------------#
# Get current date in 'yyyy-MM-dd' format
$currentDate = Get-Date -Format "yyyyMMdd"

# Folder path
$folderPath = "$($home)\Desktop\export_$currentDate"

# CSV file name
$csvFileName = "$nsgName-$currentDate.csv"

# CSV file path
$csvFilePath = Join-Path -Path $folderPath -ChildPath $csvFileName

#------------------------------------------------------------------------------------------------------------------------------------#
# Create folder if it does not exist
if (-not (Test-Path -Path $folderPath)) {
  New-Item -ItemType Directory -Path $folderPath
}
else {
  Write-Host "Destination folder already exists: $folderPath"
}


$nsgs = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Name $nsgName

foreach ($nsg in $nsgs) {
  # Custom rules
  Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg | 
  Select-Object `
  @{label = 'Resource Group Name'; expression = { $nsg.ResourceGroupName } },
  @{label = 'NSG Name'; expression = { $nsg.Name } },
  Priority, 
  @{label = 'Rule Name'; expression = { $_.Name } },
  Direction, Access, Protocol,
  @{label = 'Source'; expression = { ($_.SourceAddressPrefix -join ";") } },
  @{label = 'Source Application Security Group'; expression = { if ($_.SourceApplicationSecurityGroups) { $_.SourceApplicationSecurityGroups.id.Split('/')[-1] } else { 'None' } } },
  @{label = 'Source Port Range'; expression = { ($_.SourcePortRange -join ";") } },
  @{label = 'Destination'; expression = { ($_.DestinationAddressPrefix -join ";") } },
  @{label = 'Destination Application Security Group'; expression = { if ($_.DestinationApplicationSecurityGroups) { $_.DestinationApplicationSecurityGroups.id.Split('/')[-1] } else { 'None' } } },
  @{label = 'Destination Port Range'; expression = { ($_.DestinationPortRange -join ";") } } |
    
  Export-Csv -Path $csvFilePath -NoTypeInformation -Append -Force
    
  # Default rules
  Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg -DefaultRules | 
  Select-Object `
  @{label = 'Resource Group Name'; expression = { $nsg.ResourceGroupName } },
  @{label = 'NSG Name'; expression = { $nsg.Name } },
  Priority, 
  @{label = 'Rule Name'; expression = { $_.Name } },
  Direction, Access, Protocol,
  @{label = 'Source'; expression = { ($_.SourceAddressPrefix -join ";") } },
  @{label = 'Source Port Range'; expression = { ($_.SourcePortRange -join ";") } },
  @{label = 'Destination'; expression = { ($_.DestinationAddressPrefix -join ";") } },
  @{label = 'Destination Port Range'; expression = { ($_.DestinationPortRange -join ";") } } |
 
  Export-Csv -Path $csvFilePath -NoTypeInformation -Append -Force
}
