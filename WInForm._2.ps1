Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell WinForm - TreeView and WebBrowser"
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = "CenterScreen"

# Create MenuStrip
$menuStrip = New-Object System.Windows.Forms.MenuStrip

# File menu
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem "File"
$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem "Exit"
$exitItem.Add_Click({ $form.Close() })
$fileMenu.DropDownItems.Add($exitItem)

# Help menu
$helpMenu = New-Object System.Windows.Forms.ToolStripMenuItem "Help"
$aboutItem = New-Object System.Windows.Forms.ToolStripMenuItem "About"
$aboutItem.Add_Click({ [System.Windows.Forms.MessageBox]::Show("PowerShell WinForm Example", "About") })
$helpMenu.DropDownItems.Add($aboutItem)

$menuStrip.Items.Add($fileMenu)
$menuStrip.Items.Add($helpMenu)

$form.MainMenuStrip = $menuStrip

# Create TableLayoutPanel to hold MenuStrip and SplitContainer
$table = New-Object System.Windows.Forms.TableLayoutPanel
$table.Dock = [System.Windows.Forms.DockStyle]::Fill
$table.RowCount = 2
$table.ColumnCount = 1
$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize))) # MenuStrip
$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) # SplitContainer
$form.Controls.Add($table)

# Add MenuStrip to TableLayoutPanel row 0
$table.Controls.Add($menuStrip, 0, 0)

# Create SplitContainer
$splitContainer = New-Object System.Windows.Forms.SplitContainer
$splitContainer.Dock = [System.Windows.Forms.DockStyle]::Fill
$splitContainer.SplitterDistance = 250
$splitContainer.Orientation = [System.Windows.Forms.Orientation]::Vertical
$table.Controls.Add($splitContainer, 0, 1)

# Left pane: TreeView
$treeView = New-Object System.Windows.Forms.TreeView
$treeView.Dock = [System.Windows.Forms.DockStyle]::Fill
$splitContainer.Panel1.Controls.Add($treeView)

# Populate TreeView with drives
[System.IO.DriveInfo]::GetDrives() | ForEach-Object {
    $node = New-Object System.Windows.Forms.TreeNode $_.Name
    $node.Tag = $_.Name
    $treeView.Nodes.Add($node)
}

# Dynamically expand directories
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

# Right pane: WebBrowser
$webBrowser = New-Object System.Windows.Forms.WebBrowser
$webBrowser.Dock = [System.Windows.Forms.DockStyle]::Fill
$splitContainer.Panel2.Controls.Add($webBrowser)

# Navigate when TreeView node selected
$treeView.Add_AfterSelect({
    param($sender, $e)
    $path = $e.Node.Tag
    if (Test-Path $path) {
        $webBrowser.Navigate("file:///$path")
    }
})

# Show form
[void]$form.ShowDialog()
