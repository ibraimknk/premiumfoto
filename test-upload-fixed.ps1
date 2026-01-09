    # PowerShell 5.1 Uyumlu Upload Script - Duzeltilmis Versiyon
# Kullanım: .\test-upload-fixed.ps1 -FilePath "C:\path\to\image.jpg"

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
    # .NET HttpClient kullanarak multipart form data olustur
    Add-Type -AssemblyName System.Net.Http
    
    $httpClient = New-Object System.Net.Http.HttpClient
    $multipartContent = New-Object System.Net.Http.MultipartFormDataContent
    
    # Dosyayi oku
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
    
    # Byte array content olustur (dogru constructor kullanimi)
    $byteArrayContent = New-Object System.Net.Http.ByteArrayContent(,$fileBytes)
    $byteArrayContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($fileContentType)
    
    # Form data'ya ekle
    $multipartContent.Add($byteArrayContent, "file", $fileName)
    
    # API Key header ekle
    if ($ApiKey) {
        $httpClient.DefaultRequestHeaders.Add("x-api-key", $ApiKey)
    }
    
    # Istek gonder
    Write-Host "Sunucuya gonderiliyor..." -ForegroundColor Yellow
    $response = $httpClient.PostAsync($Url, $multipartContent).Result
    
    # Response oku
    $responseContent = $response.Content.ReadAsStringAsync().Result
    
    if ($response.IsSuccessStatusCode) {
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
    } else {
        Write-Host "Hata: HTTP $($response.StatusCode)" -ForegroundColor Red
        Write-Host "Response: $responseContent" -ForegroundColor Yellow
        
        try {
            $errorDetails = $responseContent | ConvertFrom-Json
            if ($errorDetails.error) {
                Write-Host "   Detay: $($errorDetails.error)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   Detay: $responseContent" -ForegroundColor Yellow
        }
    }
    
    # Temizlik
    $httpClient.Dispose()
    $multipartContent.Dispose()
    $byteArrayContent.Dispose()
    
} catch {
    Write-Host "Hata olustu:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.InnerException) {
        Write-Host "   Inner: $($_.Exception.InnerException.Message)" -ForegroundColor Yellow
    }
}

