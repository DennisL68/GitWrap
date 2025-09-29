
cd ~\Documents\Worddiff\

$source = @"
[DllImport("user32.dll")]
public static extern bool SetForegroundWindow(IntPtr hWnd);
"@

# Add static methods to this PowerShell session
$foregroundWindow = Add-Type `
    -MemberDefinition $source -Name "ForegroundWindowHelper" `
    -Namespace "Win32Functions" `
    -PassThru

$orgdoc = (Get-ChildItem '.\The frst doc.docx').FullName
$revdoc = (Get-ChildItem '.\The scond doc.docx').FullName

$word = New-Object -ComObject Word.Application

$doc1 = $word.Documents.Open($orgdoc, [ref]$false, [ref]$true)
$doc2 = $word.Documents.Open($revdoc, [ref]$false, [ref]$true)
$comparisonDoc = $word.CompareDocuments($doc1, $doc2)

$doc1.Close([ref]$false)
$doc2.Close([ref]$false)

$word.Visible = $true
$comparisonDoc.Activate()
$word.ActiveWindow.View.ShowReviewingPane

$wordproc = get-process winword | where MainWindowtitle -like "$($comparisonDoc.Name)*"
$foregroundWindow::SetForegroundWindow($wordproc.MainWindowHandle)
