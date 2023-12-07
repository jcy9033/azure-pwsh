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


# Initialize a flag to track if any deletion fails
$allDeletedSuccessfully = $true

foreach ($username in $usernames.Keys) {
  Write-Host "Delete user account: $username"
  
  # Execute the delete command and capture its success
  net user $username /delete
  if ($LASTEXITCODE -ne 0) {
    $allDeletedSuccessfully = $false
    Write-Host "Failed to delete user account: $username"
  }
}

# Check if all deletions were successful
if ($allDeletedSuccessfully) {
  Write-Host "All user accounts have been deleted."
}
else {
  Write-Host "Some user accounts could not be deleted."
}