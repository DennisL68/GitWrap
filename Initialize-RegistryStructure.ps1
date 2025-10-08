# Base paths
$baseKey = "HKCU:\SOFTWARE\Classes\Directory"
$shellKey = Join-Path $baseKey "Background\shell\GitWrap"
$contextMenusKey = Join-Path $baseKey "ContextMenus\GitWrap"

# Create main GitWrap menu
New-Item -Path $shellKey -Force | Out-Null
New-ItemProperty -Path $shellKey -Name "ExtendedSubCommandsKey" -Value "Directory\ContextMenus\GitWrap" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $shellKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $shellKey -Name "MUIVerb" -Value "GitWrap r0.18" -PropertyType String -Force | Out-Null

# Submenu: 00_Init
$initKey = Join-Path $contextMenusKey "shell\00_Init"
New-Item -Path $initKey -Force | Out-Null
New-ItemProperty -Path $initKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $initKey -Name "MUIVerb" -Value "Initialize File Collection [Git Init Repo] (Local)" -PropertyType String -Force | Out-Null

$initCommand = 'pwsh.exe -WindowStyle hidden -EncodedCommand IwAgAC0AL...'  # put full encoded string here
New-ItemProperty -Path $initCommandKey -Name "(Default)" -Value $initCommand -PropertyType String -Force | Out-Null

# Submenu: 01_Clone
$cloneKey = Join-Path $contextMenusKey "shell\01_Clone"
New-Item -Path $cloneKey -Force | Out-Null
New-ItemProperty -Path $cloneKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $cloneKey -Name "MUIVerb" -Value "Clone File Collection [Git Clone Repo] (Remote)" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $cloneKey -Name "CommandFlags" -Value 0x40 -PropertyType DWord -Force | Out-Null

# Submenu: 10_Commit
$commitKey = Join-Path $contextMenusKey "shell\10_Commit"
New-Item -Path $commitKey -Force | Out-Null
New-ItemProperty -Path $commitKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $commitKey -Name "MUIVerb" -Value "Store Work Area State [Git Commit Branch] (Local)" -PropertyType String -Force | Out-Null

# Submenu: 11_Branch
$branchKey = Join-Path $contextMenusKey "shell\11_Branch"
New-Item -Path $branchKey -Force | Out-Null
New-ItemProperty -Path $branchKey -Name "ExtendedSubCommandsKey" -Value "Directory\ContextMenus\GitWrap\GitWrapSub_Branch" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $branchKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $branchKey -Name "MUIVerb" -Value "Manage Work Area [Git Branch] (Local)" -PropertyType String -Force | Out-Null

# Submenu: 12_Sync
$syncKey = Join-Path $contextMenusKey "shell\12_Sync"
New-Item -Path $syncKey -Force | Out-Null
New-ItemProperty -Path $syncKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $syncKey -Name "MUIVerb" -Value "Sync Work Area [Git Pull/Push Branch] (Remote/Local)" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $syncKey -Name "CommandFlags" -Value 0x40 -PropertyType DWord -Force | Out-Null

# Submenu: 23_Status
$statusKey = Join-Path $contextMenusKey "shell\23_Status"
New-Item -Path $statusKey -Force | Out-Null
New-ItemProperty -Path $statusKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $statusKey -Name "MUIVerb" -Value "Refresh Explorer [Git Status] (Local)" -PropertyType String -Force | Out-Null

# Submenu: 24_Log
$logKey = Join-Path $contextMenusKey "shell\24_Log"
New-Item -Path $logKey -Force | Out-Null
New-ItemProperty -Path $logKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $logKey -Name "MUIVerb" -Value "View Log [Git Log] (Local)" -PropertyType String -Force | Out-Null

# Base path for branch submenu
$branchSubKeyBase = "HKCU:\SOFTWARE\Classes\Directory\ContextMenus\GitWrap\GitWrapSub_Branch\shell"

# Submenu: 10_New
$newKey = Join-Path $branchSubKeyBase "10_New"
New-Item -Path $newKey -Force | Out-Null
New-ItemProperty -Path $newKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $newKey -Name "MUIVerb" -Value "New Area [Checkout -b] (Local)" -PropertyType String -Force | Out-Null

# Submenu: 11_Switch
$switchKey = Join-Path $branchSubKeyBase "11_Switch"
New-Item -Path $switchKey -Force | Out-Null
New-ItemProperty -Path $switchKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $switchKey -Name "MUIVerb" -Value "Switch Area [Switch branch] (Local)" -PropertyType String -Force | Out-Null

# Submenu: 12_LocalDel
$localDelKey = Join-Path $branchSubKeyBase "12_LocalDel"
New-Item -Path $localDelKey -Force | Out-Null
New-ItemProperty -Path $localDelKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $localDelKey -Name "MUIVerb" -Value "Delete Area [Branch -d] (Local)" -PropertyType String -Force | Out-Null

# Submenu: 14_RefreshRemote
$refreshRemoteKey = Join-Path $branchSubKeyBase "14_RefreshRemote"
New-Item -Path $refreshRemoteKey -Force | Out-Null
New-ItemProperty -Path $refreshRemoteKey -Name "Icon" -Value "C:\Program Files\Git\git-bash.exe" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $refreshRemoteKey -Name "MUIVerb" -Value "Purge Remote Area Info [Update --prune]" -PropertyType String -Force | Out-Null

