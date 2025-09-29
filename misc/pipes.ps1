$pipeName = "MyPipe"

while ($true) {
    # Create a new pipe instance each time
    $pipe = [System.IO.Pipes.NamedPipeServerStream]::new(
        $pipeName,
        [System.IO.Pipes.PipeDirection]::In
    )

    try {
        # Wait for a client (like 'copy') to connect
        $pipe.WaitForConnection()

        # Read whatever data was sent (ignore content, just treat as signal)
        $reader = New-Object System.IO.StreamReader $pipe
        $message = $reader.ReadToEnd()

        Write-Host "Signal received from $pipeName"
    }
    finally {
        # Clean up this instance so next 'copy' can connect
        $pipe.Dispose()
    }
}

# copy nul \\.\pipe\MyPipe
