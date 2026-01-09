# PowerShell Image Upload Test Script
# Kullanım: .\test-upload.ps1 -FilePath "C:\path\to\image.jpg"

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [string]$ApiKey = "",
    [string]$Url = "https://fotougur.com.tr/api/upload"
)

# Dosya var mı kontrol et
if (-not (Test-Path $FilePath)) {
    Write-Host "❌ Hata: Dosya bulunamadı: $FilePath" -ForegroundColor Red
    exit 1
}

# Dosya tipi kontrolü
$fileExtension = [System.IO.Path]::GetExtension($FilePath).ToLower()
$allowedExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg')
if ($allowedExtensions -notcontains $fileExtension) {
    Write-Host "❌ Hata: Sadece resim dosyaları yüklenebilir" -ForegroundColor Red
    Write-Host "İzin verilen formatlar: $($allowedExtensions -join ', ')" -ForegroundColor Yellow
    exit 1
}

# Dosya boyutu kontrolü (20MB)
$fileSize = (Get-Item $FilePath).Length
$maxSize = 20 * 1024 * 1024
if ($fileSize -gt $maxSize) {
    Write-Host "❌ Hata: Dosya çok büyük ($([math]::Round($fileSize/1MB, 2))MB). Maksimum: 20MB" -ForegroundColor Red
    exit 1
}

Write-Host "📤 Fotoğraf yükleniyor..." -ForegroundColor Cyan
Write-Host "   Dosya: $FilePath" -ForegroundColor Gray
Write-Host "   Boyut: $([math]::Round($fileSize/1MB, 2))MB" -ForegroundColor Gray
Write-Host ""

try {
    # Multipart form data oluştur
    $boundary = [System.Guid]::NewGuid().ToString()
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $fileName = [System.IO.Path]::GetFileName($FilePath)
    
    # Body oluştur
    $bodyLines = @()
    $bodyLines += "--$boundary"
    $bodyLines += "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`""
    $bodyLines += "Content-Type: $(Get-ContentType -Extension $fileExtension)"
    $bodyLines += ""
    $bodyLines += [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($fileBytes)
    $bodyLines += "--$boundary--"
    
    $body = $bodyLines -join "`r`n"
    $bodyBytes = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes($body)
    
    # Headers
    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }
    
    if ($ApiKey) {
        $headers["x-api-key"] = $ApiKey
    }
    
    # İstek gönder
    $response = Invoke-RestMethod -Uri $Url -Method Post -Body $bodyBytes -Headers $headers -ContentType "multipart/form-data; boundary=$boundary"
    
    if ($response.success) {
        Write-Host "✅ Başarılı!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📸 Fotoğraf URL:" -ForegroundColor Cyan
        Write-Host "   $($response.url)" -ForegroundColor White
        Write-Host ""
        Write-Host "📋 Detaylar:" -ForegroundColor Cyan
        Write-Host "   Dosya Adı: $($response.fileName)" -ForegroundColor Gray
        Write-Host "   Boyut: $([math]::Round($response.size/1KB, 2))KB" -ForegroundColor Gray
        Write-Host "   Tip: $($response.type)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "🔗 Fotoğrafı görüntülemek için:" -ForegroundColor Yellow
        Write-Host "   $($response.url)" -ForegroundColor White
    } else {
        Write-Host "❌ Hata: $($response.error)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Hata oluştu:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        try {
            $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
            if ($errorDetails.error) {
                Write-Host "   Detay: $($errorDetails.error)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   Detay: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
        }
    }
    exit 1
}

# Content-Type helper function
function Get-ContentType {
    param([string]$Extension)
    
    $contentTypes = @{
        '.jpg'  = 'image/jpeg'
        '.jpeg' = 'image/jpeg'
        '.png'  = 'image/png'
        '.gif'  = 'image/gif'
        '.webp' = 'image/webp'
        '.svg'  = 'image/svg+xml'
    }
    
    return $contentTypes[$Extension] ?? 'application/octet-stream'
}

