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
} else {
  Write-Host "Some user accounts could not be deleted."
}