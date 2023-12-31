#-------------------------------------- Step: 1

Write-Host "Step: 1 # Microsoft Defender for Endpoint Settings. `n"


pause

#-------------------------------------- Step: 2-1
Write-Host "Step: 2-1 # Create maintenance user accounts. `n"

# Script to add user usernames and add them to the administrators group
# Create an array of usernames and passwords

$usernames = [ordered]@{
  "fjse01"     = "uuz9YleZfC7B9Z0";
  "fjse02"     = "uuz9YleZfC7B9Z0";
  "fjse03"     = "uuz9YleZfC7B9Z0";
  "fjse04"     = "uuz9YleZfC7B9Z0";
  "fjse05"     = "uuz9YleZfC7B9Z0";
  "fjop01"     = "uuz9YleZfC7B9Z0";
  "fjop02"     = "uuz9YleZfC7B9Z0";
  "fjop03"     = "uuz9YleZfC7B9Z0";
  "fjop04"     = "uuz9YleZfC7B9Z0";
  "fjop05"     = "uuz9YleZfC7B9Z0";
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

pause

#-------------------------------------- Step: 2-2
Write-Host "Step: 2-2 # Cretae a apuser account. [Options] `n"


pause

#-------------------------------------- Step: 3
Write-Host "Step: 3 # Mount data disks. [Options] `n"

# Get the raw disk numbers that are healthy, online, and have a RAW partition style

$rawDiskNumbers = Get-Disk | Where-Object { $_.HealthStatus -eq 'Healthy' -and $_.OperationalStatus -eq 'Online' -and $_.PartitionStyle -eq 'RAW' } | Select-Object -ExpandProperty Number | Sort-Object

$driveLetter = "F"

# Iterate through each raw disk number
foreach ($rawDiskNumber in $rawDiskNumbers) {
  # Initialize the disk with GPT partition style without confirmation
  Initialize-Disk -Number $rawDiskNumber -PartitionStyle GPT -Confirm:$false
  $partition = New-Partition -DiskNumber $rawDiskNumber -UseMaximumSize -DriveLetter $driveLetter

  # Check if a new partition was created
  if ($partition) {
    Write-Host "Partition created successfully on disk number $rawDiskNumber with drive letter $driveLetter"

    # Format the volume with NTFS filesystem and set the label to 'DataDisk' without confirmation
    Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel 'DataDisk' -Confirm:$false

    # Update the next drive letter
    $driveLetter = [char]([int][char]$driveLetter + 1)
  }
  else {
    Write-Host "Failed to create partition on disk number $rawDiskNumber"
  }
}

#-------------------------------------- Step: 4
Write-Host "Step: 4 # Win RM. `n"


#-------------------------------------- Step: 5
Write-Host "Step: 5 # Windows Update. `n"

# Force installation of NuGet provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Automatically skip all confirmation prompts
$ConfirmPreference = 'None'

# Check and install the PSWindowsUpdate module
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
  Write-Host "Installing PSWindowsUpdate module..."
  Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
  Import-Module PSWindowsUpdate
}
else {
  Write-Host "PSWindowsUpdate module is already installed."
}

# Display a list of available Windows updates
Write-Host "Checking for available Windows updates..."
Get-WindowsUpdate

# Install Windows updates
Write-Host "Installing Windows updates..."
Install-WindowsUpdate -AcceptAll

#-------------------------------------- Step: 6 
Write-Host "Step: 6 # Not configure. `n"

# Registry.pol path
$PolicyPath = "C:\Windows\System32\GroupPolicy\Machine\Registry.pol"

# Registry path
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Key path
$keyPath = "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Check and install the PolicyFileEditor module
if (-not (Get-Module -ListAvailable -Name PolicyFileEditor)) {
  Write-Host "Installing PSWindowsUpdate module..."
  Install-Module -Name PolicyFileEditor -Force -Confirm:$false
  Import-Module PolicyFileEditor
}
else {
  Write-Host "PolicyFileEditor module is already installed."
}

try {
  # Check if the registry key exists
  if (Test-Path $registryPath) {
    # Check for and remove values 'AUOptions', 'NoAutoUpdate', 'Scheduled*' if they exist
    $scheduledValues = (Get-ItemProperty -Path $registryPath).PSObject.Properties |
    Where-Object { $_.Name -like "Scheduled*" } |
    Select-Object -ExpandProperty Name

    foreach ($valueName in $scheduledValues) {
      if (Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue) {
        Remove-PolicyFileEntry -Path $PolicyPath -Key $keyPath -ValueName $valueName -ErrorAction Stop
      }
    }

    Write-Host "Configure Automatic Updates policy set to 'Not Configured'."
  }
  else {
    Write-Host "The registry path does not exist. The policy is probably already set to 'Not Configured'."
  }
}
catch {
  Write-Host "An error occurred: $_"
}

# Apply the changes by updating group policies
gpupdate /force /target:computer

#-------------------------------------- Step: 7
Write-Host "Step: 7 # Check the NTP settings. `n"

# NTP 상태 확인
w32tm /query /status

# NTP 설정 확인
w32tm /query /configuration

#-------------------------------------- Step: 8 Failed
Write-Host "Step: 8 - Checking the Windows license status.`n"

# Run slmgr.vbs with /dlv switch to get detailed license information
$slmgrOutput = & cscript //NoLogo C:\Windows\System32\slmgr.vbs /dlv 2>&1

# Parse the output for the 'License Status' using a regular expression
if ($slmgrOutput -match "License Status: (\w+)") {
  $licenseStatus = $matches[1] # The first match group contains the status
  Write-Host "License Status: $licenseStatus"
  if ($licenseStatus -eq "Licensed") {
    Write-Host "Windows is properly activated."
  }
  else {
    Write-Host "Windows activation may be required."
  }
}
else {
  Write-Host "Failed to determine the license status from the output."
}

#-------------------------------------- Step: 9 # Successed
Write-Host "Step: 9 - System Time Synchronization.`n"

# W32Time 서비스 상태 확인
$service = Get-Service W32Time
Write-Host "Current W32Time service status: $($service.Status)"

# W32Time 서비스 재시작
Restart-Service W32Time -Force

# 재시작 후 W32Time 서비스 상태 확인
$service = Get-Service W32Time
Write-Host "W32Time service status after restart: $($service.Status)"

# 시간 서버와 즉시 재동기화
w32tm /resync /nowait

# 시간 동기화가 완료될 때까지 대기
$timeoutSeconds = 60 # 60초 동안 대기
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

do {
  $syncStatus = w32tm /query /status
  Write-Host "Waiting for time synchronization to complete..."
  Start-Sleep -Seconds 5
} while ($syncStatus -match "Source: Local CMOS Clock" -and $stopwatch.Elapsed.TotalSeconds -lt $timeoutSeconds)

if ($stopwatch.Elapsed.TotalSeconds -ge $timeoutSeconds) {
  Write-Host "Time synchronization timed out."
}
else {
  Write-Host "Time synchronization completed."
}

# 시간 서비스 구성 쿼리
Write-Host "Time service configuration:"
w32tm /query /configuration

# 시간 서비스 상태 쿼리
Write-Host "Time service status:"
w32tm /query /status



#-------------------------------------- Step: 10 # Successed
Write-Host "Step: 10 # Change IPv6 settings to disabled. `n"

# Display current settings for ms_tcpip6 component binding
Get-NetAdapterBinding -ComponentID ms_tcpip6 | Format-Table -AutoSize

# Disable the ms_tcpip6 component binding
Get-NetAdapterBinding -ComponentID ms_tcpip6 | Disable-NetAdapterBinding

# Display current settings for ms_tcpip6 component binding after disabling
Get-NetAdapterBinding -ComponentID ms_tcpip6 | Format-Table -AutoSize

# Query the DisabledComponents value in the registry
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters /v DisabledComponents

# Set the DisabledComponents value to 0xffffffff (disabled)
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters /v DisabledComponents /t REG_DWORD /d 0xffffffff /f

# Query the DisabledComponents value in the registry after setting it to 0xffffffff
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters /v DisabledComponents




#-------------------------------------- Step: 11 # Successed
Write-Host "Step: 11 # Change the System Timezone to Japan. `n"

# 일본 타임존으로 변경
$newTimeZone = 'Tokyo Standard Time'
Set-TimeZone -Id $newTimeZone

# 변경 후 타임존 확인
Get-Timezone

#-------------------------------------- Step: 12
Write-Host "Step: 12 - Disabling IE Enhanced Security Configuration`n"

# 관리자(Administrators) 그룹에 대한 레지스트리 경로 설정
$adminRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'

# 일반 사용자(Users) 그룹에 대한 레지스트리 경로 설정
$userRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'

# 기존 설정값 조회
$beforeAdminIEESC = (Get-ItemProperty -Path $adminRegistryPath -Name 'IsInstalled').IsInstalled
$beforeUserIEESC = (Get-ItemProperty -Path $userRegistryPath -Name 'IsInstalled').IsInstalled

# IE ESC 설정 비활성화
Set-ItemProperty -Path $adminRegistryPath -Name 'IsInstalled' -Value 0
Set-ItemProperty -Path $userRegistryPath -Name 'IsInstalled' -Value 0

# 변경 후 설정값 조회
$afterAdminIEESC = (Get-ItemProperty -Path $adminRegistryPath -Name 'IsInstalled').IsInstalled
$afterUserIEESC = (Get-ItemProperty -Path $userRegistryPath -Name 'IsInstalled').IsInstalled

# 변경 전후 설정값 출력
Write-Host "Administrator IE ESC Setting change: $beforeAdminIEESC -> $afterAdminIEESC"
Write-Host "User IE ESC Setting change: $beforeUserIEESC -> $afterUserIEESC"
