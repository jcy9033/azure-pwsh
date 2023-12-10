#------------------------------------------------------------------------------------------------------------------------------------#
# Get current date in 'yyyy-MM-dd' format
$currentDate = Get-Date -Format "yyyyMMdd"

# Path of Export file destination folder
$folderPath = "$($home)\Desktop\export_$currentDate"



#------------------------------------------------------------------------------------------------------------------------------------#
# Create folder if it does not exist
if (-not (Test-Path -Path $folderPath)) {
  New-Item -ItemType Directory -Path $folderPath
}
else {
  Write-Host "Destination folder already exists.: $folderPath"
}


$nsgs = Get-AzNetworkSecurityGroup

foreach ($nsg in $nsgs) {
  # CSV file name
  $csvFileName = "$($nsg.name)-$currentDate.csv"

  # Destination folder absolute path of CSV file 
  $csvFilePath = Join-Path -Path $folderPath -ChildPath $csvFileName

  # Custom rules
  Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg | 
  Select-Object `
  @{label = 'Resource Group Name'; expression = { $nsg.ResourceGroupName } },
  @{label = 'NSG Name'; expression = { $nsg.Name } },
  Priority, 
  @{label = 'Rule Name'; expression = { $_.Name } },
  Direction, Access,
  @{label = 'Source'; expression = { ($_.SourceAddressPrefix -join ";") } },
  @{label = 'Source Application Security Group'; expression = { if ($_.SourceApplicationSecurityGroups) { $_.SourceApplicationSecurityGroups.id.Split('/')[-1] } else { 'None' } } },
  @{label = 'Source Port Range'; expression = { ($_.SourcePortRange -join ";") } },
  @{label = 'Destination'; expression = { ($_.DestinationAddressPrefix -join ";") } },
  @{label = 'Destination Application Security Group'; expression = { if ($_.DestinationApplicationSecurityGroups) { $_.DestinationApplicationSecurityGroups.id.Split('/')[-1] } else { 'None' } } },
  @{label = 'Destination Port Range'; expression = { ($_.DestinationPortRange -join ";") } } |
    
  Export-Csv -Path $csvFilePath -NoTypeInformation -Append -Force
    
  # default rules
  Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg -DefaultRules | 
  Select-Object `
  @{label = 'Resource Group Name'; expression = { $nsg.ResourceGroupName } },
  @{label = 'NSG Name'; expression = { $nsg.Name } },
  Priority, 
  @{label = 'Rule Name'; expression = { $_.Name } },
  Direction, Access,
  @{label = 'Source'; expression = { ($_.SourceAddressPrefix -join ";") } },
  @{label = 'Source Application Security Group'; expression = { if ($_.SourceApplicationSecurityGroups) { $_.SourceApplicationSecurityGroups.id.Split('/')[-1] } else { 'None' } } },
  @{label = 'Source Port Range'; expression = { ($_.SourcePortRange -join ";") } },
  @{label = 'Destination'; expression = { ($_.DestinationAddressPrefix -join ";") } },
  @{label = 'Destination Application Security Group'; expression = { if ($_.DestinationApplicationSecurityGroups) { $_.DestinationApplicationSecurityGroups.id.Split('/')[-1] } else { 'None' } } },
  @{label = 'Destination Port Range'; expression = { ($_.DestinationPortRange -join ";") } } |
 
  Export-Csv -Path $csvFilePath -NoTypeInformation -Append -Force
}
