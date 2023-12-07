# User list
$usernames = @("user1", "user2", "user3", "user4", "user5", "user6", "user7", "user8", "user9")

# User name
Write-Host "User name:"
hostname
Write-Host "--------------------------"

foreach ($username in $usernames) {
    Write-Host "User name: $username"
    net user $username
    Write-Host "--------------------------"
}
