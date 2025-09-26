; # -------------
; # Switch Branch
; # -------------

; Add-Type -AssemblyName PresentationFramework

; # https://unicode.org/emoji/charts/full-emoji-list.html
; $CheckMark  = "`u{2714}"
; $CrossMark  = "`u{274C}"
; $Warning    = "`u{26A0}"
; $Prohibited = "`{1F6AB}"
; $BlackCircle = "`u{26AB}"
; $WhiteCircle = "`u{26AA}"
; $Triangle   = "`u{1F53A}"
; $ShuffleTrack = "`u{1F500}"

; try {
;     $DirtyStatus = git status --porcelain 2>&1
;     if ($DirtyStatus.Exception.Message -like 'fatal:*') {throw}
; } catch {
;     [System.Windows.MessageBox]::Show(# error
;         $DirtyStatus.Exception.Message,'GitWrap',0,'Error',0,'DefaultDesktopOnly'
;     )
;     return
; }

; if ($DirtyStatus) {
;     $Choice = [System.Windows.MessageBox]::Show(#status
;         "Repository isn't in a clean status. `n" +
;         "It contains untracked or changed files.`n`n" +
;         "$DirtyStatus `n`n" +
;         "WARNING: Clicking 'OK' to continue switching branch `n" + 
;         "might move the file(s) along.",
;         'GitWrap','OkCancel','Warning','Cancel','DefaultDesktopOnly'
;     )
;     if ($Choice -ne 'Ok') {return}
; }

; try {
;     $Result = git branch -a 2>&1
;     if ($Result[-1].Exception.Message -Like 'fatal:*') {throw}

; } catch {
;     [System.Windows.MessageBox]::Show(# error
;         $Result[-1].Exception.Message,'GitWrap',0,'Error',0,'DefaultDesktopOnly'
;     )
;     return
; }

; [string[]]$Branches = $Result | where {$_ -notlike '*HEAD*'}

; try {
;     $Branch = $Branches | Out-GridView -Title 'GitWrap - Switch Branch [SELECT BRANCH]' -OutputMode Single
;     if (!$Branch) {throw}

; } catch {
;     [System.Windows.MessageBox]::Show(# error
;         'Error in parameter input','GitWrap',0,'Error',0,'DefaultDesktopOnly'
;     )
;     return
; }

; $Branch = [regex]::Replace($Branch,'^..remotes/.*?/|^..','') # remove 'remotes/origin/' or two first chars

; try {
;     $Result = git switch $Branch 2>&1
;     if ($Result.Exception.Message -like 'fatal:*') {throw}

; } catch {
;     [System.Windows.MessageBox]::Show(# error
;         $Result.Exception.Message,'GitWrap',0,'Error',0,'DefaultDesktopOnly'
;     )
;     return
; }

; [System.Windows.MessageBox]::Show(# result
;     $Result[0],'GitWrap',0,'Info',0,'DefaultDesktopOnly'
; )

; # Update File Explorer
; $ThisGitStatus = Write-VcsStatus
; $ThisGitStatus = $ThisGitStatus | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' }
; $ThisGitStatus = $ShuffleTrack + ' ' + (Get-GitStatus).RepoName + ' ' + $ThisGitStatus

; Add-Type -Namespace Util -Name WinApi  -MemberDefinition @"
;   [DllImport("user32.dll")]
;   public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
; "@

; $hwndTopMostFileExplorer = [Util.WinApi]::FindWindow(
;   "CabinetWClass",     # the window class of interest
;   [NullString]::Value  # no window title to search for
; )

; Add-Type -TypeDefinition @"
; using System;
; using System.Runtime.InteropServices;

; public static class Win32 {
;   [DllImport("User32.dll", CharSet=CharSet.Unicode, EntryPoint="SetWindowText")]
;   public static extern int SetWindowText(IntPtr hWnd, string strTitle);
; }
; "@

; [Win32]::SetWindowText($hwndTopMostFileExplorer, $ThisGitStatus)
