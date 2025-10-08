// cmd.exe /c echo show > \\.\pipe\GitWrap

var args = WScript.Arguments;

if (args.length === 0) {
    WScript.Echo("No arguments provided.");
    WScript.Quit(-1);
}

// Command to send
var command = args(0);

var shell = new ActiveXObject("WScript.Shell");

// Build the cmd.exe command
// /c = execute and exit
// > \\.\pipe\GitWrap sends text to the pipe
var cmdCommand = 'cmd.exe /c echo %cd%' + command + ' > \\\\.\\pipe\\GitWrap';

// Run hidden (0) and wait until finished (true)
shell.Run(cmdCommand, 0, true);
