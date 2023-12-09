# Script to add user usernames and add them to the administrators group
# Create an array of usernames and passwords

$usernames = [ordered]@{
  "user1" = "uuz9YleZfC7B9Z0";
  "user2" = "uuz9YleZfC7B9Z0";
  "user3" = "uuz9YleZfC7B9Z0";
  "user4" = "uuz9YleZfC7B9Z0";
  "user5" = "uuz9YleZfC7B9Z0";
  "user6" = "uuz9YleZfC7B9Z0";
  "user7" = "uuz9YleZfC7B9Z0";
  "user8" = "uuz9YleZfC7B9Z0";
  "user9" = "uuz9YleZfC7B9Z0";
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
  }
  else {
    Write-Host "The command completed successfully.`n"
  }

  Write-Host "#.Remove the user from the Users group"
  net localgroup "Users" $username /delete
  if ($LASTEXITCODE -ne 0) { $allCommandsSuccessful = $false }
}

# Check if all commands were successful
if ($allCommandsSuccessful) {
  Write-Host "All user usernames have been added, and settings have been applied."
}
else {
  Write-Host "Some operations failed. Please check the log for more details."
}