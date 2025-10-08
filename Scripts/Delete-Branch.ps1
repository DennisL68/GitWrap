# -------------
# Delete Branch
# -------------

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

try {
    [string[]]$Result = git branch -l 2>&1
    if ($Result.Exception) {throw -ErrorAction Stop}

} catch {
    [System.Windows.MessageBox]::Show(#error
        $Result[0],'GitWrap',0,'Error',0,'DefaultDesktopOnly'
    )
    return
}

$Branches = $Result

try {
    $BranchToDelete = $Branches | Out-GridView -Title 'GitWrap - Delete Branch [SELECT BRANCH]' -OutputMode Single
    $BranchToDelete = $BranchToDelete.Substring(2)
    if (!$BranchToDelete) {throw -ErrorAction stop}
    if (
        $BranchToDelete -eq 'master' -or
        $BranchToDelete -eq 'main'
    ) {throw -ErrorAction stop}

} catch {
    [System.Windows.MessageBox]::Show(#error
        'Error in parameter input','GitWrap',0,'Error',0,'DefaultDesktopOnly'
    )
    return
}

$ThisBranch = ((git branch -l) | where {$_ -like '`**'}).Substring(2)
$RemoteBranches = git branch -r

if (!$RemoteBranches) {# ask to merge with local branch
    $MergeToMain = [System.Windows.MessageBox]::Show(
        "Content of [$BranchToDelete] needs to `n be merged to Main before beeing removed.`n`nMerge to Main?",
        'GitWrap - Merge before deletion','YesNo','Exclamation','No','DefaultDesktopOnly'
    )
    if ($MergeToMain -eq 'No') {# abort deletion
        return
    }
    git switch main
    git merge $BranchToDelete
    git swich $ThisBranch
}

try {
    [string[]]$Result = git branch -d $BranchToDelete 2>&1
    if ($Result.Exception) {throw -ErrorAction Stop}
    if (
        $Result -like "fatal*" -or
        $Result -like "error*"
    ) {throw -ErrorAction Stop}

} catch {
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
$ThisGitStatus = $ShuffleTrack + ' ' + (Get-GitStatus).RepoName + ' ' + $ThisGitStatus

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

[Win32]::SetWindowText($hwndTopMostFileExplorer, $ThisGitStatus)
