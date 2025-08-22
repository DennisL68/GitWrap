# GitWrap

## 1. Description

GitWrap is a very simple GUI-wrapper that integrates with Windows Explorer for `Git for Windows`.  
The integration is done all in user mode context and requires no admin privileges.

The purpose is to take the edge off the steep initial learning curve for people that are used to graphical interfaces when working with files.

GitWrap will add a few context menus that allows the user to right-click in the Explorer to perform the most common Git tasks.  
It will also add the current Git status to the top most File Explorer window.

## 2. Requirements

The prerequisites for applying all features of this repo is

* PowerShell 7.x
* Git for Windows
* posh-git

The following provides some enancements to this solution

* TortioseGit

## 3. Limitations

* Windows File Explorer only support 16 static context menu per entry.
To by-pass this limitations, some of the code in [Adam the Automator - How to Build a PowerShell Form Menu for your PowerShell Scripts][7] will be tried out in a future version.

* The current implementation of `GitWrap` is a prototyped version that breaks `Windows Security` and requires `Real-time protection` in `Virus and threat protection` to be turned **off**.  
**THIS IS NOT A RECOMMENDED ACTION!**

## 4. How do I use this repo?

Apply the reg files, disable `Real-time protection` and you are done.

To change the code, uncomment the PowerShell scripts within the reg files.
Apply your changes and test by hand (no unit tests available yet).

To "complie" the script into a registry `command @`, run all the code, making the last row convert the here 
string to Base64, and paste the resulting string to the reg `command @` after `Encoding`. 
Remember to keep the registry command as a string.

Before applying any changes, make sure to delete any old application entries in key `HKCU\SOFTWARE\Classes\Directory\ContextMenus\GitWrap`.

## 5. References and links

* [Git for Windows][1]
* [PowerShell 7.0 (LTS)][2]
* [PowerShell 7.2 (LTS)][3]
* [PowerShell 7.4 (LTS)][4]
* [TortoiseGit][5]
* [Creating Shortcut Menu Handlers][6]

## 6. Contacts

Please contact the author for any questions or if you'd like to help out.

[1]:https://gitforwindows.org/
[2]:https://learn.microsoft.com/en-us/previous-versions/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7
[3]:https://learn.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-72?view=powershell-7.2
[4]:https://learn.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-74?view=powershell-7.4
[5]:https://tortoisegit.org/download/
[6]:https://learn.microsoft.com/en-us/windows/win32/shell/context-menu-handlers
[7]:https://adamtheautomator.com/powershell-form/
