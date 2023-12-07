# Script to add user usernames and add them to the administrators group
# Create an array of usernames and passwords

$usernames = [ordered]@{
  "fjse01"     = "fsse01##fsse01##fsse01##";
  "fjse02"     = "fsse02##fsse02##fsse02##";
  "fjse03"     = "fsse03##fsse03##fsse03##";
  "fjse04"     = "fsse04##fsse04##fsse04##";
  "fjse05"     = "fsse05##fsse05##fsse05##";
  "fjop01"     = "fsop01##fsop01##fsop01##";
  "fjop02"     = "fsop02##fsop02##fsop02##";
  "fjop03"     = "fsop03##fsop03##fsop03##";
  "fjop04"     = "fsop04##fsop04##fsop04##";
  "fjop05"     = "fsop05##fsop05##fsop05##";
  "iac-user01" = "@Fujitsuse!234S6";
}

# Initialize a flag to track if any command fails
$allCommandsSuccessful = $true

foreach ($username in $usernames.Keys) {
  $password = $usernames[$username]
  
  Write-Host "#.Add user username: $username -------------*"
  net user $username $password /add /Y
  if ($LASTEXITCODE -ne 0) { $allCommandsSuccessful = $false }
  
  Write-Host "#.Add user to the Administrators group"
  net localgroup "Administrators" $username /add
  if ($LASTEXITCODE -ne 0) { $allCommandsSuccessful = $false }
  
  Write-Host "#.Disable password expiration"
  wmic useraccount where "Name='$username'" set PasswordExpires=FALSE > $null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to disable password expiration for $username.`n"
    $allCommandsSuccessful = $false
  } else {
    Write-Host "The command completed successfully.`n"
  }

  Write-Host "#.Remove the user from the Users group"
  net localgroup "Users" $username /delete
  if ($LASTEXITCODE -ne 0) { $allCommandsSuccessful = $false }
}

# Check if all commands were successful
if ($allCommandsSuccessful) {
  Write-Host "All user usernames have been added, and settings have been applied."
} else {
  Write-Host "Some operations failed. Please check the log for more details."
}