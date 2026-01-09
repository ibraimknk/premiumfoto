# cURL ile Test - Gerçek cURL kullanarak
# Kullanım: .\test-curl-upload.ps1 -FilePath "C:\path\to\image.jpg"

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [string]$ApiKey = "",
    [string]$Url = "https://fotougur.com.tr/api/upload"
)

Write-Host "cURL ile fotograf yukleniyor..." -ForegroundColor Cyan
Write-Host "   Dosya: $FilePath" -ForegroundColor Gray
Write-Host ""

# Dosya var mi kontrol et
if (-not (Test-Path $FilePath)) {
    Write-Host "Hata: Dosya bulunamadi: $FilePath" -ForegroundColor Red
    exit 1
}

# cURL komutu olustur
$curlCmd = "curl.exe -X POST `"$Url`" -F `"file=@$FilePath`""

if ($ApiKey) {
    $curlCmd += " -H `"x-api-key: $ApiKey`""
}

Write-Host "Komut: $curlCmd" -ForegroundColor Gray
Write-Host ""

# cURL'u calistir
try {
    $output = Invoke-Expression $curlCmd 2>&1
    
    # JSON parse etmeyi dene
    try {
        $result = $output | ConvertFrom-Json
        
        if ($result.success) {
            Write-Host "Basarili!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Fotograf URL:" -ForegroundColor Cyan
            Write-Host "   $($result.url)" -ForegroundColor White
        } else {
            Write-Host "Hata: $($result.error)" -ForegroundColor Red
        }
    } catch {
        # JSON degilse direkt goster
        Write-Host "Response:" -ForegroundColor Yellow
        Write-Host $output
    }
} catch {
    Write-Host "Hata: $($_.Exception.Message)" -ForegroundColor Red
}

