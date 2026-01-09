# Alternatif Upload Yontemi - WebClient kullanarak
# Kullanım: .\test-upload-alternative.ps1 -FilePath "C:\path\to\image.jpg"

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [string]$ApiKey = "",
    [string]$Url = "https://fotougur.com.tr/api/upload"
)

Write-Host "Fotograf yukleniyor (Alternatif Yontem)..." -ForegroundColor Cyan
Write-Host "   Dosya: $FilePath" -ForegroundColor Gray
Write-Host ""

# Dosya var mi kontrol et
if (-not (Test-Path $FilePath)) {
    Write-Host "Hata: Dosya bulunamadi: $FilePath" -ForegroundColor Red
    exit 1
}

try {
    # WebClient kullanarak multipart form data olustur
    $boundary = [System.Guid]::NewGuid().ToString()
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $fileName = [System.IO.Path]::GetFileName($FilePath)
    $fileExtension = [System.IO.Path]::GetExtension($FilePath).ToLower()
    
    # Content-Type belirle
    $contentTypeMap = @{
        '.jpg'  = 'image/jpeg'
        '.jpeg' = 'image/jpeg'
        '.png'  = 'image/png'
        '.gif'  = 'image/gif'
        '.webp' = 'image/webp'
        '.svg'  = 'image/svg+xml'
    }
    $fileContentType = $contentTypeMap[$fileExtension]
    if (-not $fileContentType) {
        $fileContentType = 'application/octet-stream'
    }
    
    # Multipart body olustur
    $bodyLines = New-Object System.Collections.ArrayList
    $bodyLines.Add("--$boundary") | Out-Null
    $bodyLines.Add("Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"") | Out-Null
    $bodyLines.Add("Content-Type: $fileContentType") | Out-Null
    $bodyLines.Add("") | Out-Null
    
    # Header kismini byte'a cevir
    $headerText = ($bodyLines -join "`r`n") + "`r`n"
    $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headerText)
    
    # Footer
    $footerText = "`r`n--$boundary--`r`n"
    $footerBytes = [System.Text.Encoding]::ASCII.GetBytes($footerText)
    
    # Tum body'yi birlestir
    $totalLength = $headerBytes.Length + $fileBytes.Length + $footerBytes.Length
    $bodyBytes = New-Object byte[] $totalLength
    
    [System.Buffer]::BlockCopy($headerBytes, 0, $bodyBytes, 0, $headerBytes.Length)
    [System.Buffer]::BlockCopy($fileBytes, 0, $bodyBytes, $headerBytes.Length, $fileBytes.Length)
    [System.Buffer]::BlockCopy($footerBytes, 0, $bodyBytes, $headerBytes.Length + $fileBytes.Length, $footerBytes.Length)
    
    # WebRequest olustur
    $request = [System.Net.WebRequest]::Create($Url)
    $request.Method = "POST"
    $request.ContentType = "multipart/form-data; boundary=$boundary"
    $request.ContentLength = $bodyBytes.Length
    
    # API Key header ekle
    if ($ApiKey) {
        $request.Headers.Add("x-api-key", $ApiKey)
    }
    
    # Body'yi gonder
    Write-Host "Sunucuya gonderiliyor..." -ForegroundColor Yellow
    $requestStream = $request.GetRequestStream()
    $requestStream.Write($bodyBytes, 0, $bodyBytes.Length)
    $requestStream.Close()
    
    # Response al
    $response = $request.GetResponse()
    $responseStream = $response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($responseStream)
    $responseContent = $reader.ReadToEnd()
    $reader.Close()
    $responseStream.Close()
    $response.Close()
    
    # JSON parse et
    $result = $responseContent | ConvertFrom-Json
    
    if ($result.success) {
        Write-Host "Basarili!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Fotograf URL:" -ForegroundColor Cyan
        Write-Host "   $($result.url)" -ForegroundColor White
        Write-Host ""
        Write-Host "Fotografi goruntulemek icin tarayicida acin:" -ForegroundColor Yellow
        Write-Host "   $($result.url)" -ForegroundColor White
        
        # Tarayicida ac (opsiyonel)
        $open = Read-Host "Tarayicida acmak ister misiniz? (y/n)"
        if ($open -eq 'y' -or $open -eq 'Y') {
            Start-Process $result.url
        }
    } else {
        Write-Host "Hata: $($result.error)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Hata olustu:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $errorReader = New-Object System.IO.StreamReader($errorStream)
            $errorBody = $errorReader.ReadToEnd()
            $errorReader.Close()
            $errorStream.Close()
            
            Write-Host "   Response: $errorBody" -ForegroundColor Yellow
            
            try {
                $errorJson = $errorBody | ConvertFrom-Json
                if ($errorJson.error) {
                    Write-Host "   Hata: $($errorJson.error)" -ForegroundColor Red
                }
            } catch {
                # JSON degil
            }
        } catch {
            Write-Host "   Response okunamadi" -ForegroundColor Gray
        }
    }
}

