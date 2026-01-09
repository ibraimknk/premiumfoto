# 🪟 PowerShell ile Fotoğraf Upload - Windows

Windows PowerShell'de `curl` komutu aslında `Invoke-WebRequest`'in bir alias'ıdır ve gerçek cURL syntax'ını desteklemez. Bu yüzden PowerShell için özel script'ler hazırladık.

## 🚀 Hızlı Kullanım

### Yöntem 1: Basit Script (Önerilen)

```powershell
# Script'i çalıştır
.\test-upload-simple.ps1 -FilePath "C:\Users\DELL\Desktop\resim.jpg"
```

### Yöntem 2: Gelişmiş Script

```powershell
# API Key ile
.\test-upload.ps1 -FilePath "C:\Users\DELL\Desktop\resim.jpg" -ApiKey "your-api-key"
```

## 📝 Manuel PowerShell Komutu

### PowerShell 7+ (Invoke-RestMethod ile -Form parametresi)

```powershell
$filePath = "C:\Users\DELL\Desktop\resim.jpg"
$url = "https://fotougur.com.tr/api/upload"

# Form data oluştur
$form = @{
    file = Get-Item -Path $filePath
}

# İstek gönder
$response = Invoke-RestMethod -Uri $url -Method Post -Form $form

# Sonucu göster
Write-Host "Fotoğraf URL: $($response.url)"
```

### API Key ile

```powershell
$filePath = "C:\Users\DELL\Desktop\resim.jpg"
$url = "https://fotougur.com.tr/api/upload"
$apiKey = "your-api-key-here"

$form = @{
    file = Get-Item -Path $filePath
}

$headers = @{
    "x-api-key" = $apiKey
}

$response = Invoke-RestMethod -Uri $url -Method Post -Form $form -Headers $headers
Write-Host "Fotoğraf URL: $($response.url)"
```

## 🔧 PowerShell 5.1 için (Eski Versiyon)

Eğer PowerShell 5.1 kullanıyorsanız ve `-Form` parametresi yoksa:

```powershell
$filePath = "C:\Users\DELL\Desktop\resim.jpg"
$url = "https://fotougur.com.tr/api/upload"

# Multipart form data manuel oluştur
$boundary = [System.Guid]::NewGuid().ToString()
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$fileName = [System.IO.Path]::GetFileName($filePath)

$bodyLines = @()
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`""
$bodyLines += "Content-Type: image/jpeg"
$bodyLines += ""
$bodyLines += [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($fileBytes)
$bodyLines += "--$boundary--"

$body = $bodyLines -join "`r`n"
$bodyBytes = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes($body)

$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

$response = Invoke-RestMethod -Uri $url -Method Post -Body $bodyBytes -Headers $headers
Write-Host "Fotoğraf URL: $($response.url)"
```

## 🧪 Test Script'leri

### 1. test-upload-simple.ps1 (Önerilen)

En basit ve kolay kullanımlı script. PowerShell 7+ için optimize edilmiş.

**Kullanım:**
```powershell
.\test-upload-simple.ps1 -FilePath "C:\path\to\image.jpg"
```

**API Key ile:**
```powershell
.\test-upload-simple.ps1 -FilePath "C:\path\to\image.jpg" -ApiKey "your-key"
```

### 2. test-upload.ps1

Daha detaylı hata kontrolü ve eski PowerShell versiyonları için uyumlu.

**Kullanım:**
```powershell
.\test-upload.ps1 -FilePath "C:\path\to\image.jpg"
```

## 📋 Örnek Kullanımlar

### Birden Fazla Dosya Yükleme

```powershell
$files = @(
    "C:\Users\DELL\Desktop\resim1.jpg",
    "C:\Users\DELL\Desktop\resim2.jpg",
    "C:\Users\DELL\Desktop\resim3.jpg"
)

$url = "https://fotougur.com.tr/api/upload"

foreach ($file in $files) {
    Write-Host "Yükleniyor: $file" -ForegroundColor Cyan
    
    $form = @{
        file = Get-Item -Path $file
    }
    
    $response = Invoke-RestMethod -Uri $url -Method Post -Form $form
    
    if ($response.success) {
        Write-Host "✅ $($response.url)" -ForegroundColor Green
    } else {
        Write-Host "❌ Hata: $($response.error)" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 1
}
```

### Klasördeki Tüm Resimleri Yükleme

```powershell
$folder = "C:\Users\DELL\Desktop\resimler"
$url = "https://fotougur.com.tr/api/upload"

Get-ChildItem -Path $folder -Filter "*.jpg" | ForEach-Object {
    Write-Host "Yükleniyor: $($_.Name)" -ForegroundColor Cyan
    
    $form = @{
        file = $_
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Form $form
        
        if ($response.success) {
            Write-Host "✅ $($response.url)" -ForegroundColor Green
            # URL'yi dosyaya kaydet
            "$($_.Name) -> $($response.url)" | Out-File -FilePath "uploaded-urls.txt" -Append
        }
    } catch {
        Write-Host "❌ Hata: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 1
}
```

## ⚠️ Sorun Giderme

### "Invoke-RestMethod : A parameter cannot be found that matches parameter name 'Form'"

Bu hata PowerShell 5.1'de görülür. Çözüm:
- PowerShell 7+ yükleyin, veya
- `test-upload.ps1` script'ini kullanın (eski versiyonlar için uyumlu)

### "Execution Policy" Hatası

```powershell
# Script çalıştırma izni ver
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Dosya Bulunamadı

Dosya yolunun doğru olduğundan emin olun:
```powershell
Test-Path "C:\Users\DELL\Desktop\resim.jpg"
```

## 🔗 Gerçek cURL Kullanmak İsterseniz

Windows'ta gerçek cURL'u kullanmak için:

1. **cURL'u yükleyin:**
   - Windows 10 1803+ ile birlikte gelir
   - Veya [curl.se](https://curl.se/windows/) adresinden indirin

2. **Kullanın:**
```powershell
# PowerShell'de curl.exe kullanın (alias değil)
curl.exe -X POST https://fotougur.com.tr/api/upload -F "file=@C:\Users\DELL\Desktop\resim.jpg"
```

## 📞 Yardım

Sorun yaşarsanız:
1. PowerShell versiyonunuzu kontrol edin: `$PSVersionTable`
2. Script'i çalıştırırken hata mesajlarını okuyun
3. API endpoint'inin çalıştığından emin olun: `Invoke-RestMethod -Uri "https://fotougur.com.tr/api/upload" -Method Get`

