# -------------
# Init new repo
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

function Get-GitId {
    function GitWrap_EnterId {
    param (
        [Parameter (Mandatory = $true)]
        [string]$YourDisplayName,

        [Parameter (Mandatory = $true)]
        [string]$YourMailAdress
    )

    [PSCustomObject]@{
        DisplayName = $YourDisplayName
        Address = $YourMailAdress
    }

    <#
    .PARAMETER YourDisplayName
        Enter your Full Name

    .PARAMETER YourMailAdress
        Enter you email address
    #>
    }

    Invoke-Expression (Show-Command GitWrap_EnterId -PassThru)
}

function Initialize-GitClone {
    try {
        # Git Init
        [string[]]$Result = git init 2>&1
        if ($Result.Exception) {throw}

        # Git Authority
        $DisplayName = git config user.name
        $Address = git config user.email

        if (!$DisplayName -or !$Address) {# Prompt for ID

            try {
                $GitId = Get-GitId
            } catch {
                Remove-Item .git -Recurse -Force

                [System.Windows.MessageBox]::Show(#error
                'An ID is required for using a Git repository','GitWrap',0,'Error',0,'DefaultDesktopOnly'
                ) | Out-Null

                return
            }
        } else {
            $GitId = [PSCustomObject]@{
                DisplayName = $DisplayName
                Address = $Address
            }
        }# endif

        try {
            [mailaddress]($GitId.DisplayName + ' ' + $GitId.Address) | Out-Null
        } catch {
            Remove-Item .git -Recurse -Force

            [System.Windows.MessageBox]::Show(#error
                'Cannot convert value of GitID to type "System.Net.Mail.MailAddress"','GitWrap',0,'Error',0,'DefaultDesktopOnly'
            ) | Out-Null

            return
        }

        git config --local user.name $GitId.DisplayName
        git config --local user.email $GitId.Address

        # Create ReadMe
    @"
# Headline

## 1. Description

[* What is this repo used for/What are we doing with this?]  
[* What is "this"?]  
[* What is the overall functionality of "this"?]  
[* Who is the target audience for this repo?]  
[* What is the purpose of this repo?]  

## 2. Prerequisites

[* What do I need to use this repo (knowledge, permissions, tools, etc.)?]  

## 3. Usage

[* Getting started]  
[* Further readings]  

## 4. References and links

[* Where can I found out more about this?]  

## 5. Contacts

[* Who should I talk with if I have questions or like to help out?]  

"@ | Out-File .\ReadMe.md -NoClobber -ErrorVariable ThisError

        [string[]]$Result = $ThisError.ErrorRecord
        if ($Result) {throw}

        # Git Add
        [string[]]$Result = git add . 2>&1
        if ($Result.Exception) {throw}

        # Git Commit
        [string[]]$Result = git commit -m'chore: Init' 2>&1
        if ($Result.Exception) {throw}
        if (($Result | Select -Index 1) -like 'nothing to commit*') {
            $Result[0] = $Result[1]
            throw
        }
        if ($Result[0] -like 'Author identity unknown') {throw}

    } catch {
        [System.Windows.MessageBox]::Show(#error
            $Result[0],'GitWrap',0,'Error',0,'DefaultDesktopOnly'
        ) | Out-Null
        return
    }

    [System.Windows.MessageBox]::Show(#result
        $Result[0],'GitWrap',0,'Info',0,'DefaultDesktopOnly'
    ) | Out-Null

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

}
