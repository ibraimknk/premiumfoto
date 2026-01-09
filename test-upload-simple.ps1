# Basit PowerShell Upload Test
# PowerShell 7+ icin: -Form parametresi kullanir
# PowerShell 5.1 icin: test-upload-ps5.ps1 kullanin
# Kullanım: .\test-upload-simple.ps1 -FilePath "C:\path\to\image.jpg"

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [string]$ApiKey = "",
    [string]$Url = "https://fotougur.com.tr/api/upload"
)

# PowerShell versiyonunu kontrol et
$psVersion = $PSVersionTable.PSVersion.Major

Write-Host "Fotograf yukleniyor..." -ForegroundColor Cyan
Write-Host "   Dosya: $FilePath" -ForegroundColor Gray
Write-Host "   PowerShell Version: $psVersion" -ForegroundColor Gray
Write-Host ""

# Dosya var mi kontrol et
if (-not (Test-Path $FilePath)) {
    Write-Host "Hata: Dosya bulunamadi: $FilePath" -ForegroundColor Red
    exit 1
}

try {
    if ($psVersion -ge 7) {
        # PowerShell 7+ icin -Form parametresi kullan
        $form = @{
            file = Get-Item -Path $FilePath
        }
        
        $headers = @{}
        if ($ApiKey) {
            $headers["x-api-key"] = $ApiKey
        }
        
        $response = Invoke-RestMethod -Uri $Url -Method Post -Form $form -Headers $headers
    } else {
        # PowerShell 5.1 icin .NET HttpClient kullan
        Write-Host "PowerShell 5.1 tespit edildi, .NET HttpClient kullaniliyor..." -ForegroundColor Yellow
        
        Add-Type -AssemblyName System.Net.Http
        
        $httpClient = New-Object System.Net.Http.HttpClient
        $multipartContent = New-Object System.Net.Http.MultipartFormDataContent
        
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
        
        $byteArrayContent = New-Object System.Net.Http.ByteArrayContent($fileBytes)
        $byteArrayContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($fileContentType)
        $multipartContent.Add($byteArrayContent, "file", $fileName)
        
        if ($ApiKey) {
            $httpClient.DefaultRequestHeaders.Add("x-api-key", $ApiKey)
        }
        
        $httpResponse = $httpClient.PostAsync($Url, $multipartContent).Result
        $responseContent = $httpResponse.Content.ReadAsStringAsync().Result
        
        if ($httpResponse.IsSuccessStatusCode) {
            $response = $responseContent | ConvertFrom-Json
        } else {
            throw "HTTP $($httpResponse.StatusCode): $responseContent"
        }
        
        $httpClient.Dispose()
        $multipartContent.Dispose()
        $byteArrayContent.Dispose()
    }
    
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
}

