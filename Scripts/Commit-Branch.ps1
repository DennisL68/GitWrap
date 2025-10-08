# -------------------
# Conventional Commit
# -------------------

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

function Get-ConventionalCommit {
    function GitWrap_CommitMessage {
        param (
            [validateset ('feat','refact','fix','docs','chore','test')]
            [string]$_WorkType,

            [string]$Reference,

            [string]$WorkDescription
        )

        if (!$_WorkType -or !$WorkDescription) {throw}

        if ($Reference) {
            $Reference = '(' + $Reference + ')'
        }

    
        ($_WorkType + $Reference + ': ' + $WorkDescription)

        <#
        .SYNOPSIS
            Enter mandatory message for storing new state of work (commit).

        .PARAMETER _WorkType
            Enter on of the folowing type of work to be performed in the new work area

            feat:   added new function/feature/textpart
            refac:  changed code/text without altering the outcome/meaning
            fix:    fixed a bug or a typo
            docs:   managed/wrte documents, help, instructions etc.
            chore:  other changes that doesn't alter meaning/functionality
            test:   description of how to perform a test or code for testing
        
        .PARAMETER Reference
            Reference to detailed information about the new work area

        .PARAMETER WorkDescription
            Enter purpose of the new work area (branch).
        #>
    }

    Invoke-Expression (Show-Command GitWrap_CommitMessage -PassThru)
}

$FirstGitStatus = Get-GitStatus
$BranchName = $FirstGitStatus.Branch
$RepoHasUpStream = [Boolean]$FirstGitStatus.Upstream

if (
    $RepoHasUpStream -and
    (
        $BranchName -eq 'master' -or
        $BranchName -eq 'main'
    )
) {
    $ContinueCommit = [System.Windows.MessageBox]::Show(
        "This repo is part of a remote repo. `n" + 
        "Remote repos usually has a lock setup on $BranchName remotely.`n" +
        "Commiting might make the local branch unusable.`n`n" +
        "Continue anyway?",
        "GitWrap - Commiting to $BranchName",'YesNo','Warning','No','DefaultDesktopOnly'
    )

    if ($ContinueCommit -eq 'No') {
        Return
    }
}

try {
    $DirtyStatus = git status --porcelain 2>&1
    if ($DirtyStatus.Exception.Message -like "fatal:*") {throw}

    $UntrackedFiles = [string[]]$DirtyStatus -match '^.\w|.\?' #Second letter used
    $UncommitedFiles = [string[]]$DirtyStatus -match '^\w|\?' #First letter used

    if (!$UntrackedFiles -and !$UncommitedFiles) {
        $Result = 'No untracked or uncomitted files'
        throw
    }

    if ($UntrackedFiles) {
        git add . 2>&1
    }

    try {
        $CommitMessage = Get-ConventionalCommit
    } catch {
        [System.Windows.MessageBox]::Show(#error
            'Error in parameter input','GitWrap',0,'Error',0,'DefaultDesktopOnly'
        )
        return
    }

    $Result = git commit -m"$CommitMessage" 2>&1
    if ($Result.Exception.Message) {throw}

    $Amend = git commit --amend 2>&1
    if (
        $Amend.Exception.Message -and
        $Amend[0].Exception.Message -notlike "unix2dos:*" -and
        $Amend[1].Exception.Message -notlike "dos2unix:*"
    ) {throw}

} catch {
    [System.Windows.MessageBox]::Show(#error
        $Result,'GitWrap',0,'Error',0,'DefaultDesktopOnly'
    )
    return
}

[System.Windows.MessageBox]::Show(#result
    $Result[1],'GitWrap',0,'Info',0,'DefaultDesktopOnly'
)

# Update File Explorer
$ThisGitPromptStatus = Write-VcsStatus
$ThisGitPromptStatus = $ThisGitPromptStatus | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' } #clean out ANSI
$ThisGitPromptStatus = $ShuffleTrack + ' ' + $FirstGitStatus.RepoName + ' ' + $ThisGitPromptStatus

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

[Win32]::SetWindowText($hwndTopMostFileExplorer, $ThisGitPromptStatus)
