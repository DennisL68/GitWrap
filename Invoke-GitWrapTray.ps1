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

    $pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream("GitWrap", [System.IO.Pipes.PipeDirection]::In)
    while ($true) {
        $trayIcon = $LocalStructure["trayIcon"]
        $pipeServer.WaitForConnection()
        $reader = New-Object System.IO.StreamReader($pipeServer)
        $command = ($reader.ReadLine()).Trim()
        
        switch ($command) {
            "show" {
                $trayIcon.ShowBalloonTip(2000, "GitWrap", "Pipe message received!", [System.Windows.Forms.ToolTipIcon]::Info)
            }
            "exit" {
                $trayIcon.Visible = $false; [System.Windows.Forms.Application]::Exit()
                exit
            }
        }
        $pipeServer.Disconnect()
    }
} -ArgumentList $SharedStructure


# Keep the app running until Exit is clicked
[System.Windows.Forms.Application]::Run()

Get-Job | Remove-Job -Force
