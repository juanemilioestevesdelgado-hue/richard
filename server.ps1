$port = 8080
$path = "c:\APLICACIONES EMILIO WEB\inventario-5ta-brigada"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running at http://localhost:$port/"
Write-Host "Press Ctrl+C to stop."

Start-Process "http://localhost:$port/"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $response = $context.Response
        $request = $context.Request

        $urlPath = $request.Url.LocalPath
        if ($urlPath -eq "/") { $urlPath = "/index.html" }
        
        # Security: prevent directory traversal
        $urlPath = $urlPath.Replace("/", "\")
        $filePath = Join-Path $path $urlPath
        
        if (Test-Path $filePath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            
            # Simple MIME types
            if ($filePath -match '\.css$') { $response.ContentType = 'text/css' }
            elseif ($filePath -match '\.js$') { $response.ContentType = 'application/javascript' }
            elseif ($filePath -match '\.html$') { $response.ContentType = 'text/html; charset=utf-8' }
            
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
