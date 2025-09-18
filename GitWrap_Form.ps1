#check module Microsoft.PowerShell.ThreadJob

$InitGitClone = [scriptblock]::Create(
    (Get-Content .\Init_GitClone.ps1 -Raw)
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;

public class ShellIcon {
    [DllImport("Shell32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr ExtractIcon(IntPtr hInst, string lpszExeFileName, int nIconIndex);
}
"@

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "GitWrap rX.X"
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = "CenterScreen"

# MenuStrip
$menuStrip = New-Object System.Windows.Forms.MenuStrip

$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem "File"
    $initItem = New-Object System.Windows.Forms.ToolStripMenuItem "Initialize File Collection"
    $initItem.Add_Click({ Start-ThreadJob {Initialize-GitClone} -InitializationScript $InitGitClone })
    $fileMenu.DropDownItems.Add($initItem)

    $cloneItem = New-Object System.Windows.Forms.ToolStripMenuItem "Clone File Collection"
    $fileMenu.DropDownItems.Add($cloneItem)

    $exitItem = New-Object System.Windows.Forms.ToolStripMenuItem "Exit"
    $exitItem.Add_Click({ $form.Close() })
    $fileMenu.DropDownItems.Add($exitItem)

    $menuStrip.Items.Add($fileMenu)

<# $collectionMenu = New-Object System.Windows.Forms.ToolStripMenuItem "Collection"
    $initItem = New-Object System.Windows.Forms.ToolStripMenuItem "Initialize File Collection"
    $collectionMenu.DropDownItems.Add($initItem)

    $cloneItem = New-Object System.Windows.Forms.ToolStripMenuItem "Clone File Collection"
    $collectionMenu.DropDownItems.Add($cloneItem)

    $menuStrip.Items.Add($collectionMenu)
 #>
$workMenu =  New-Object System.Windows.Forms.ToolStripMenuItem "Work Area"
    $storeState = New-Object System.Windows.Forms.ToolStripMenuItem "Store Work State"
    $workMenu.DropDownItems.Add($storeState)

    $manageWorkSubMenu = New-Object System.Windows.Forms.ToolStripMenuItem "Manage Area"

        $newArea = New-Object System.Windows.Forms.ToolStripMenuItem "Create New..."
        $manageWorkSubMenu.DropDownItems.Add($newArea)

        $switchArea = New-Object System.Windows.Forms.ToolStripMenuItem "Switch..."
        $manageWorkSubMenu.DropDownItems.Add($switchArea)

        $deleteArea = New-Object System.Windows.Forms.ToolStripMenuItem "Delete..."
        $manageWorkSubMenu.DropDownItems.Add($deleteArea)

        $purgeRemote = New-Object System.Windows.Forms.ToolStripMenuItem "Purge Remote Info"
        $manageWorkSubMenu.DropDownItems.Add($purgeRemote)

    $workMenu.DropDownItems.Add($manageWorkSubMenu)

    $syncWork = New-Object System.Windows.Forms.ToolStripMenuItem "Sync Area"
    $workMenu.DropDownItems.Add($syncWork)

    $menuStrip.Items.Add($workMenu)

$conflictMenu = New-Object System.Windows.Forms.ToolStripMenuItem "Resolve Conflicts"

    $resolveWord = New-Object System.Windows.Forms.ToolStripMenuItem "Word files..."
    $conflictMenu.DropDownItems.Add($resolveWord)

    $menuStrip.Items.Add($conflictMenu)

$helpMenu = New-Object System.Windows.Forms.ToolStripMenuItem "Help"
    $aboutItem = New-Object System.Windows.Forms.ToolStripMenuItem "About"
    $aboutItem.Add_Click({ [System.Windows.Forms.MessageBox]::Show("GitWrap rX.X", "About") })
    $helpMenu.DropDownItems.Add($aboutItem)

    $menuStrip.Items.Add($helpMenu)

$form.MainMenuStrip = $menuStrip

# TableLayoutPanel to prevent MenuStrip overlap
$table = New-Object System.Windows.Forms.TableLayoutPanel
$table.Dock = [System.Windows.Forms.DockStyle]::Fill
$table.RowCount = 2
$table.ColumnCount = 1
$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize))) # MenuStrip
$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) # SplitContainer
$form.Controls.Add($table)
$table.Controls.Add($menuStrip, 0, 0)

# SplitContainer
$splitContainer = New-Object System.Windows.Forms.SplitContainer
$splitContainer.Dock = [System.Windows.Forms.DockStyle]::Fill
$splitContainer.Panel1MinSize = 18
$splitContainer.SplitterDistance = 18
$splitContainer.IsSplitterFixed = $false
$splitContainer.Orientation = [System.Windows.Forms.Orientation]::Vertical
$table.Controls.Add($splitContainer, 0, 1)

# Left pane: TreeView
$imageList = New-Object System.Windows.Forms.ImageList
$imageList.ImageSize = New-Object System.Drawing.Size(16,16)
$driveIconPtr = [ShellIcon]::ExtractIcon([IntPtr]::Zero, "$env:SystemRoot\System32\shell32.dll", 4)
$driveIcon = [System.Drawing.Icon]::FromHandle($driveIconPtr)
$imageList.Images.Add("drive",$driveIcon)
$folderIconPtr = [ShellIcon]::ExtractIcon([IntPtr]::Zero, "$env:SystemRoot\System32\shell32.dll", 3)
$folderIcon = [System.Drawing.Icon]::FromHandle($folderIconPtr)
$imageList.Images.Add("folder",$folderIcon)
$treeView = New-Object System.Windows.Forms.TreeView
$treeView.Dock = [System.Windows.Forms.DockStyle]::Fill
$treeView.ImageList = $imageList
$splitContainer.Panel1.Controls.Add($treeView)

# Top node "This PC"
$topNode = New-Object System.Windows.Forms.TreeNode("This PC")
$topNode.ImageKey = "folder"
$topNode.SelectedImageKey = "folder"
#$tree.Nodes.Add($topNode)

# Populate TreeView with drives
foreach ($drive in [System.IO.DriveInfo]::GetDrives()) {
    $node = New-Object System.Windows.Forms.TreeNode($drive.Name)
    $node.Tag = $drive.RootDirectory.FullName
    $node.ImageKey = "drive"
    $node.SelectedImageKey = "drive"
    $topNode.Nodes.Add($node)
}

$treeView.Nodes.Add($topNode)
<# 
[System.IO.DriveInfo]::GetDrives() | ForEach-Object {
    $node = New-Object System.Windows.Forms.TreeNode $_.Name
    $node.Tag = $_.Name
    $treeView.Nodes.Add($node)
}
#>

# Expand directories dynamically
$treeView.Add_BeforeExpand({
    param($sender, $e)
    if ($e.Node.Nodes.Count -eq 0) {
        try {
            Get-ChildItem -Path $e.Node.Tag -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $childNode = New-Object System.Windows.Forms.TreeNode $_.Name
                $childNode.Tag = $_.FullName
                $e.Node.Nodes.Add($childNode)
            }
        } catch {}
    }
})

# Right pane: Panel to hold toolbar and WebBrowser
$rightPanel = New-Object System.Windows.Forms.Panel
$rightPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$splitContainer.Panel2.Controls.Add($rightPanel)

# Toolbar panel
$toolbar = New-Object System.Windows.Forms.Panel
$toolbar.Height = 40
$toolbar.Dock = [System.Windows.Forms.DockStyle]::Top
$rightPanel.Controls.Add($toolbar)

# Add 3 buttons to toolbar
$btn1 = New-Object System.Windows.Forms.Button
$btn1.Text = "Back"
$btn1.Width = 60
$btn1.Location = New-Object System.Drawing.Point(5,5)
$toolbar.Controls.Add($btn1)

$btn2 = New-Object System.Windows.Forms.Button
$btn2.Text = "Forward"
$btn2.Width = 60
$btn2.Location = New-Object System.Drawing.Point(70,5)
$toolbar.Controls.Add($btn2)

$btn3 = New-Object System.Windows.Forms.Button
$btn3.Text = "Refresh"
$btn3.Width = 60
$btn3.Location = New-Object System.Drawing.Point(135,5)
$toolbar.Controls.Add($btn3)

# WebBrowser
$webBrowser = New-Object System.Windows.Forms.WebBrowser
$webBrowser.Dock = [System.Windows.Forms.DockStyle]::Fill
$rightPanel.Controls.Add($webBrowser)
$webBrowser.BringToFront()

# Button functionality
$btn1.Add_Click({ if ($webBrowser.CanGoBack) { $webBrowser.GoBack() } })
$btn2.Add_Click({ if ($webBrowser.CanGoForward) { $webBrowser.GoForward() } })
$btn3.Add_Click({ $webBrowser.Refresh() })

# Navigate when TreeView node selected
$treeView.Add_AfterSelect({
    param($sender, $e)
    #Wait-Debugger
    $path = $e.Node.Nodes.Tag
    if (Test-Path $path) {
        $webBrowser.Navigate("file:///$path")
    }
})

# Show form
[void]$form.ShowDialog()
