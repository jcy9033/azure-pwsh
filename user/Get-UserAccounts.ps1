# User list
$usernames = @("fjse01", "fjse02", "fjse03", "fjse04", "fjse05", "fjop01", "fjop02", "fjop03", "fjop04", "fjop05", "iac-user01")

# User name
Write-Host "User name:"
hostname
Write-Host "--------------------------"

foreach ($username in $usernames) {
    Write-Host "User name: $username"
    net user $username
    Write-Host "--------------------------"
}
