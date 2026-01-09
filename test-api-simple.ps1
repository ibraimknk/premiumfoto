# Basit API Test - Endpoint'in calisip calismadigini kontrol et
$url = "https://fotougur.com.tr/api/upload"

Write-Host "API endpoint test ediliyor..." -ForegroundColor Cyan
Write-Host "URL: $url" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $url -Method Get
    Write-Host "API calisiyor!" -ForegroundColor Green
    Write-Host ""
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Hata:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "HTTP Status: $statusCode" -ForegroundColor Yellow
    }
}

