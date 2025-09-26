# -------------
# Create Branch
# -------------

Add-Type -AssemblyName PresentationFramework

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("User32.dll", CharSet=CharSet.Unicode, EntryPoint="SetWindowText")]
    public static extern int SetWindowText(IntPtr hWnd, string strTitle);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# https://unicode.org/emoji/charts/full-emoji-list.html
$CheckMark  = "`u{2714}"
$CrossMark  = "`u{274C}"
$Warning    = "`u{26A0}"
$Prohibited = "`{1F6AB}"
$BlackCircle = "`u{26AB}"
$WhiteCircle = "`u{26AA}"
$Triangle   = "`u{1F53A}"
$ShuffleTrack = "`u{1F500}"

function Get-BranchName {
    function GitWrap_BranchInfo {
        param (
            [Parameter(Mandatory=$true)]
            [validateset ('feat','refact','fix','docs','chore','test')]
            [string]$_WorkType,

            [Parameter(Mandatory=$true)]
            [string]$Reference,

            [Parameter(Mandatory=$true)]
            [string]$WorkDescription
        )

        ($_WorkType + '_' + $Reference + '_' + $WorkDescription) -replace '!|^-|\?|\*|\\|\/|\.$|\.{2}|\[|\]| ','_' -replace 'å|ä','a' -replace 'ö','o' #replace some foreign characters

        <#
        .SYNOPSIS
            Enter mandatory parameters for creating a new work area (branch).

        .PARAMETER WorkType
            Enter on of the folowing type of work to be performed in the new work area

            feat:   adding new function/feature/textpart
            refac:  changing code/text without altering the outcome/meaning
            fix:    fixing a bug or a typo
            docs:   managing/writing documents, help, instructions etc.
            chore:  other changes that doesn't alter meaning/functionality
            test:   description of how to perform a test or code for testing
        
        .PARAMETER WorkReference
            Reference to detailed information about the new work area

        .PARAMETER WorkDescription
            Enter purpose of the new work area (branch).
        #>
    }

    Invoke-Expression (Show-Command GitWrap_BranchInfo -PassThru)
}

try {$BranchName = Get-BranchName} catch {
    [System.Windows.MessageBox]::Show(# error
        'Error in parameter input','GitWrap',0,'Error',0,'DefaultDesktopOnly'
    )
    return
}

try {
    [string[]]$Result = git checkout -b $BranchName 2>&1
    if ($Result.Exception) {throw}

    [string[]]$Result = git add . 2>&1
    if ($Result.Exception) {throw}

} catch {
    [System.Windows.MessageBox]::Show(# error
        $Result[0],'GitWrap',0,'Error',0,'DefaultDesktopOnly'
    )
    return
}

[System.Windows.MessageBox]::Show(# result
    $Result[0],'GitWrap',0,'Info',0,'DefaultDesktopOnly'
)

# Update File Explorer
$ThisGitStatus = Write-VcsStatus
$ThisGitStatus = $ThisGitStatus | ForEach-Object { $_ -replace '\x1b\[[0-9;]*m','' }
$ThisGitStatus = $ShuffleTrack + ' ' + (Get-GitStatus).RepoName + ' ' + $ThisGitStatus

Add-Type -Namespace Util -Name WinApi -MemberDefinition @"
  [DllImport("user32.dll")]
  public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
"@

$hwndTopMostFileExplorer = [Util.WinApi]::FindWindow(
  "CabinetWClass",     # the window class of interest
  [NullString]::Value  # no window title to search for
)

[Win32]::SetWindowText($hwndTopMostFileExplorer, $ThisGitStatus)
