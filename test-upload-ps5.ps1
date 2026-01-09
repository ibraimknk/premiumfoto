# PowerShell 5.1 Uyumlu Upload Script
# Kullanım: .\test-upload-ps5.ps1 -FilePath "C:\path\to\image.jpg"

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [string]$ApiKey = "",
    [string]$Url = "https://fotougur.com.tr/api/upload"
)

Write-Host "Fotograf yukleniyor..." -ForegroundColor Cyan
Write-Host "   Dosya: $FilePath" -ForegroundColor Gray
Write-Host ""

# Dosya var mi kontrol et
if (-not (Test-Path $FilePath)) {
    Write-Host "Hata: Dosya bulunamadi: $FilePath" -ForegroundColor Red
    exit 1
}

try {
    # Multipart form data olustur (PowerShell 5.1 icin)
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
    
    # Body olustur
    $bodyLines = New-Object System.Collections.ArrayList
    $bodyLines.Add("--$boundary") | Out-Null
    $bodyLines.Add("Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"") | Out-Null
    $bodyLines.Add("Content-Type: $fileContentType") | Out-Null
    $bodyLines.Add("") | Out-Null
    
    # Dosya icerigini ekle
    $bodyText = $bodyLines -join "`r`n"
    $bodyBytes = [System.Text.Encoding]::ASCII.GetBytes($bodyText)
    
    # Dosya byte'larini ekle
    $combinedBytes = New-Object byte[] ($bodyBytes.Length + $fileBytes.Length + 2 + $boundary.Length + 4)
    [System.Buffer]::BlockCopy($bodyBytes, 0, $combinedBytes, 0, $bodyBytes.Length)
    [System.Buffer]::BlockCopy($fileBytes, 0, $combinedBytes, $bodyBytes.Length, $fileBytes.Length)
    
    # Son boundary ekle
    $endBoundary = "`r`n--$boundary--`r`n"
    $endBytes = [System.Text.Encoding]::ASCII.GetBytes($endBoundary)
    [System.Buffer]::BlockCopy($endBytes, 0, $combinedBytes, $bodyBytes.Length + $fileBytes.Length, $endBytes.Length)
    
    # Headers
    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }
    
    if ($ApiKey) {
        $headers["x-api-key"] = $ApiKey
    }
    
    # Istek gonder
    Write-Host "Sunucuya gonderiliyor..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $Url -Method Post -Body $combinedBytes -Headers $headers
    
    if ($response.success) {
        Write-Host "Basarili!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Fotograf URL:" -ForegroundColor Cyan
        Write-Host "   $($response.url)" -ForegroundColor White
        Write-Host ""
        Write-Host "Fotografi goruntulemek icin tarayicida acin:" -ForegroundColor Yellow
        Write-Host "   $($response.url)" -ForegroundColor White
        
        # Tarayicida ac (opsiyonel)
        $open = Read-Host "Tarayicida acmak ister misiniz? (y/n)"
        if ($open -eq 'y' -or $open -eq 'Y') {
            Start-Process $response.url
        }
    } else {
        Write-Host "Hata: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "Hata olustu:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        try {
            $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
            if ($errorDetails.error) {
                Write-Host "   Detay: $($errorDetails.error)" -ForegroundColor Yellow
            }
        } catch {
            $errorMsg = $_.ErrorDetails.Message
            Write-Host "   Detay: $errorMsg" -ForegroundColor Yellow
        }
    }
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response: $responseBody" -ForegroundColor Yellow
    }
}

