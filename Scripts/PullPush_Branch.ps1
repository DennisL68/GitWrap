# -----------
# Sync Remote
# -----------

Add-Type -AssemblyName PresentationFramework

# https://unicode.org/emoji/charts/full-emoji-list.html
$CheckMark  = "`u{2714}"
$CrossMark  = "`u{274C}"
$Warning    = "`u{26A0}"
$Prohibited = "`{1F6AB}"
$BlackCircle = "`u{26AB}"
$WhiteCircle = "`u{26AA}"
$Triangle   = "`u{1F53A}"
$ShuffleTrack = "`u{1F500}"

$ProgressBlock = {
[console]::WindowHeight = 2
#[console]::BufferHeight = 2

[console]::WindowWidth = 40
[console]::BufferWidth = 40

[console]::Title = 'GitWrap'

while ($true) {
    1..100 | foreach {
        Write-Progress -Activity " Processing" -Status "`0" -PercentComplete $_
        Start-Sleep -Milliseconds 50
    }
}
}

$ThisBranch = ((git branch -l) | where {$_ -like '`**'}).Substring(2)
try {
    $RemoteBranches = (git branch -r).replace('origin/','').substring(2)

    if (!($Thisbranch -in $RemoteBranches)) {# the local branch hasn't been pushed
        $Progress = Start-Process PWSH "-noprofile -command $ProgressBlock" -PassThru
        git push --set-upstream origin $ThisBranch
        $Progress.Kill()
    }
    
} catch {# repo has no remotes at all
    $Progress.Kill()
}


try {
    $Progress = Start-Process PWSH "-noprofile -command $ProgressBlock" -PassThru

    [string[]]$Result = git pull 2>&1
    if ($Result.Exception) {throw -ErrorAction Stop}

    [string[]]$Result = git push 2>&1
    if ($Result.Exception) {throw -ErrorAction Stop}

    $Progress.Kill()

} catch {
    $Progress.Kill()
    [System.Windows.MessageBox]::Show(#error
        $Result[0],'GitWrap',0,'Error',0,'DefaultDesktopOnly'
    )
    return
}

[System.Windows.MessageBox]::Show(#result
    $Result[0],'GitWrap',0,'Info',0,'DefaultDesktopOnly'
)

# Update File Explorer
$ThisGitStatus = Write-VcsStatus
$ThisGitStatus = $ThisGitStatus | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' }
$ThisGitStatus =  $ShuffleTrack + ' ' + (Get-GitStatus).RepoName + ' ' + $ThisGitStatus

Add-Type -Namespace Util -Name WinApi  -MemberDefinition @"
  [DllImport("user32.dll")]
  public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
"@

$hwndTopMostFileExplorer = [Util.WinApi]::FindWindow(
  "CabinetWClass",     # the window class of interest
  [NullString]::Value  # no window title to search for
)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class Win32 {
  [DllImport("User32.dll", CharSet=CharSet.Unicode, EntryPoint="SetWindowText")]
  public static extern int SetWindowText(IntPtr hWnd, string strTitle);
}
"@
