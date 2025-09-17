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

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Embedded Explorer with Sidebar, Toolbar, and Column Bar"
$form.Size = New-Object System.Drawing.Size(1000,600)

# SplitContainer
$split = New-Object System.Windows.Forms.SplitContainer
$split.Dock = [System.Windows.Forms.DockStyle]::Fill
$split.Panel1MinSize = 16
$split.SplitterDistance = 16
$split.IsSplitterFixed = $false
$form.Controls.Add($split)

# Sidebar TreeView with icons
$imageList = New-Object System.Windows.Forms.ImageList
$imageList.ImageSize = New-Object System.Drawing.Size(16,16)
$driveIconPtr = [ShellIcon]::ExtractIcon([IntPtr]::Zero, "$env:SystemRoot\System32\shell32.dll", 4)
$driveIcon = [System.Drawing.Icon]::FromHandle($driveIconPtr)
$imageList.Images.Add("drive",$driveIcon)
$folderIconPtr = [ShellIcon]::ExtractIcon([IntPtr]::Zero, "$env:SystemRoot\System32\shell32.dll", 3)
$folderIcon = [System.Drawing.Icon]::FromHandle($folderIconPtr)
$imageList.Images.Add("folder",$folderIcon)

$tree = New-Object System.Windows.Forms.TreeView
$tree.Dock = [System.Windows.Forms.DockStyle]::Fill
$tree.ImageList = $imageList
$split.Panel1.Controls.Add($tree)

# Top node "This PC"
$topNode = New-Object System.Windows.Forms.TreeNode("This PC")
$topNode.ImageKey = "folder"
$topNode.SelectedImageKey = "folder"
$tree.Nodes.Add($topNode)

# Add drives as child nodes
foreach ($drive in [System.IO.DriveInfo]::GetDrives()) {
    $node = New-Object System.Windows.Forms.TreeNode($drive.Name)
    $node.Tag = $drive.RootDirectory.FullName
    $node.ImageKey = "drive"
    $node.SelectedImageKey = "drive"
    $topNode.Nodes.Add($node)
}
$topNode.Expand()

# Folder panel (right)
$folderPanel = New-Object System.Windows.Forms.Panel
$folderPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$split.Panel2.Controls.Add($folderPanel)

# Toolbar inside folder panel
$toolStrip = New-Object System.Windows.Forms.ToolStrip
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$folderPanel.Controls.Add($toolStrip)
$btnBack = New-Object System.Windows.Forms.ToolStripButton("←")
$btnForward = New-Object System.Windows.Forms.ToolStripButton("→")
$btnUp = New-Object System.Windows.Forms.ToolStripButton("↑")
$toolStrip.Items.AddRange(@($btnBack,$btnForward,$btnUp))


# WebBrowser below toolbar and column bar
$webBrowser = New-Object System.Windows.Forms.WebBrowser
$webBrowser.Dock = [System.Windows.Forms.DockStyle]::Fill
$folderPanel.Controls.Add($webBrowser)
$webBrowser.BringToFront()

# Initial folder
$currentFolder = "C:\"
$webBrowser.Url = New-Object System.Uri("file:///$($currentFolder -replace '\\','/')")

# Toolbar button events
$btnBack.Add_Click({ if ($webBrowser.CanGoBack) { $webBrowser.GoBack() } })
$btnForward.Add_Click({ if ($webBrowser.CanGoForward) { $webBrowser.GoForward() } })
$btnUp.Add_Click({
    $parent = [System.IO.Directory]::GetParent($webBrowser.Url.LocalPath)
    if ($parent) {
        $webBrowser.Url = New-Object System.Uri("file:///$($parent.FullName -replace '\\','/')")
    }
})

# TreeView selection
$tree.Add_AfterSelect({
    param($sender,$e)
    $folderPath = $e.Node.Tag
    if ($folderPath) {
        $webBrowser.Url = New-Object System.Uri("file:///$($folderPath -replace '\\','/')")
        # Populate subfolders dynamically
        $e.Node.Nodes.Clear()
        try {
            foreach ($sub in [System.IO.Directory]::GetDirectories($folderPath)) {
                $subNode = New-Object System.Windows.Forms.TreeNode([System.IO.Path]::GetFileName($sub))
                $subNode.Tag = $sub
                $subNode.ImageKey = "folder"
                $subNode.SelectedImageKey = "folder"
                $e.Node.Nodes.Add($subNode)
            }
        } catch {}
    }
})

# Show form
[void]$form.ShowDialog()
