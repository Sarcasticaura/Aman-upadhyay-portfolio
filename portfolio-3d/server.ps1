$port = 8080
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

$workspace = $PSScriptRoot

Write-Host "Starting server..."
try {
    $listener.Start()
    Write-Host "Local web server running successfully!"
    Write-Host "👉 Open http://localhost:$port in your browser."
    Write-Host "Press Ctrl+C in this terminal to stop the server."
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $url = $request.Url.LocalPath
        if ($url -eq "/") { $url = "/index.html" }

        # Construct absolute path in the workspace
        $filePath = Join-Path $workspace $url.SubString(1)
        
        if (Test-Path $filePath -PathType Leaf) {
            # Determine content type
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            switch ($ext) {
                ".html" { $contentType = "text/html; charset=utf-8" }
                ".css" { $contentType = "text/css; charset=utf-8" }
                ".js" { $contentType = "application/javascript; charset=utf-8" }
                ".png" { $contentType = "image/png" }
                ".jpg" { $contentType = "image/jpeg" }
                ".jpeg" { $contentType = "image/jpeg" }
                ".gif" { $contentType = "image/gif" }
                ".svg" { $contentType = "image/svg+xml" }
                ".woff2" { $contentType = "font/woff2" }
                ".woff" { $contentType = "font/woff" }
                ".ttf" { $contentType = "font/ttf" }
                ".json" { $contentType = "application/json" }
                ".mp3" { $contentType = "audio/mpeg" }
                ".wav" { $contentType = "audio/wav" }
                ".gltf" { $contentType = "model/gltf+json" }
                ".glb" { $contentType = "model/gltf-binary" }
                default { $contentType = "application/octet-stream" }
            }

            $response.ContentType = $contentType
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        $response.Close()
    }
} catch {
    Write-Host "Error: $_"
} finally {
    $listener.Stop()
    Write-Host "Server stopped."
}
