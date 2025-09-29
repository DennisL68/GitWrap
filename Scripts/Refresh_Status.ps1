# --------------------
# Update File Explorer
# --------------------

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
