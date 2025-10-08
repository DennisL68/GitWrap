### Check requirements
try {#for Git
    git.exe | Out-Null
} catch {
    throw 'Git for Windows is missing.'
    return
}

if (-not (Get-Module Posh-Git -ListAvailable)) {
    throw 'Module Posh-Git is missing.'
    return
}

if (
    $PSVersionTable.PSVersion.Major -eq '5' -and
    -not (Get-Module Microsoft.PowerShell.ThreadJob -ListAvailable)
) {
    throw 'Module Microsoft.PowerShell.ThreadJob is missing.'
    return
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Global:SharedStructure = [hashtable]::Synchronized(@{})

# Create a new NotifyIcon object
$trayIcon = New-Object System.Windows.Forms.NotifyIcon
$trayIcon.Icon = [System.Drawing.SystemIcons]::Information
$trayIcon.Text = "GitWrap"
$trayIcon.Visible = $true

$Global:SharedStructure["trayIcon"] = $trayIcon

# Create a context menu with an Exit option
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem "Exit"
$exitItem.Add_Click({
    $trayIcon.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})
$contextMenu.Items.Add($exitItem)
$trayIcon.ContextMenuStrip = $contextMenu

# Show a balloon tip
$trayIcon.ShowBalloonTip(3000, "GitWrap", "Running in the background!", [System.Windows.Forms.ToolTipIcon]::Info)

Start-ThreadJob {
     param (
        $LocalStructure
    )

    ### Load Scriptblocks
    $InitGitRepo = [scriptblock]::Create(
        (Get-Content .\Scripts\Init_GitRepo.ps1 -Raw -ErrorAction Stop)
    )

    $CloneGitRemote = [scriptblock]::Create(
        (Get-Content .\Scripts\Clone_GitRemote.ps1 -Raw -ErrorAction Stop)
    )

    $CommitBranch = [scriptblock]::Create(
        (Get-Content .\Scripts\Commit-Branch.ps1 -Raw -ErrorAction Stop)
    )

    $NewBranch = [scriptblock]::Create(
        (Get-Content .\Scripts\New_Branch.ps1 -Raw -ErrorAction Stop)
    )

    $SwitchBranch = [scriptblock]::Create(
        (Get-Content .\Scripts\Switch_Branch.ps1 -Raw -ErrorAction Stop)
    )

    $DeleteBranch = [scriptblock]::Create(
        (Get-Content .\Scripts\Delete-Branch.ps1 -Raw -ErrorAction Stop)
    )

    $PruneRemote = [scriptblock]::Create(
        (Get-Content .\Scripts\Prune_Remote.ps1 -Raw -ErrorAction Stop)
    )

    $PullPush = [scriptblock]::Create(
        (Get-Content .\Scripts\PullPush_Branch.ps1 -Raw -ErrorAction Stop)
    )

    $RefreshBranchStatus = [scriptblock]::Create(
        (Get-Content .\Scripts\Refresh_Status.ps1 -Raw -ErrorAction Stop)
    )

    $GetBranchHistory = [scriptblock]::Create(
        (Get-Content .\Scripts\Get_BranchLog.ps1 -Raw -ErrorAction Stop)
    )

    $GetRepoHistory = [scriptblock]::Create(
        (Get-Content .\Scripts\Get_RepoLog.ps1 -Raw -ErrorAction Stop)
    )

    #Create pipeServer
    $pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream(
        "GitWrap",
        [System.IO.Pipes.PipeDirection]::In
    )


    while ($true) {
        $trayIcon = $LocalStructure["trayIcon"]
        $pipeServer.WaitForConnection()
        $reader = New-Object System.IO.StreamReader($pipeServer)

        $commandLine = $reader.ReadLine() #Should recieve a JSON-array with two values
        $CommandJson = $commandLine.Replace('\','\\') | ConvertFrom-Json

        $Path   = $CommandJson[0]
        $Command = $CommandJson[1]
        
        switch ($Command) {
            "show" {
                $trayIcon.ShowBalloonTip(2000, "GitWrap", "Pipe message received!", [System.Windows.Forms.ToolTipIcon]::Info)
            }
            "exit" {
                $pipeServer.Disconnect()
                $pipeServer.Dispose()
                $trayIcon.Visible = $false
                [System.Windows.Forms.Application]::Exit()
                exit
            }
        }

        $pipeServer.Disconnect()
    }
} -ArgumentList $SharedStructure

#* Needed to be able to run runspace debugger. Remember to terminate the TrayIcon manually.
# return 

# Keep the app running until Exit is clicked
[System.Windows.Forms.Application]::Run()

#Signal the ThreadJob to Exit
    $pipe = [System.IO.Pipes.NamedPipeClientStream]::new(".", "GitWrap", [System.IO.Pipes.PipeDirection]::Out)
    $pipe.Connect()
    $writer = [System.IO.StreamWriter]::new($pipe)
    $writer.AutoFlush = $true
    $writer.WriteLine("exit")
    $writer.Dispose()
    $pipe.Dispose()

Get-Job | Remove-Job -Force
