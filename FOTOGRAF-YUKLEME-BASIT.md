# 📸 Fotoğraf Yükleme - Basit Kullanım

## 🚀 API Key Olmadan Yükleme

API key **opsiyonel**. Eğer `.env` dosyasında `UPLOAD_API_KEY` tanımlı değilse, API key göndermenize gerek yok.

## 💻 Windows PowerShell ile Yükleme

### Yöntem 1: Hazır Script (Önerilen)

```powershell
# Windows PowerShell'de
cd "C:\Users\DELL\Desktop\premium foto"

# API key olmadan yükle
.\test-upload-working.ps1 -FilePath "C:\Users\DELL\Desktop\resim.jpg"
```

### Yöntem 2: Manuel PowerShell Komutu

```powershell
# Dosya yolunu belirle
$filePath = "C:\Users\DELL\Desktop\resim.jpg"
$url = "https://fotougur.com.tr/api/upload"

# .NET HttpClient kullan
Add-Type -AssemblyName System.Net.Http
$httpClient = New-Object System.Net.Http.HttpClient
$multipartContent = New-Object System.Net.Http.MultipartFormDataContent

# Dosyayı oku
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$fileName = [System.IO.Path]::GetFileName($filePath)

# ByteArrayContent oluştur
$byteArrayContent = [System.Net.Http.ByteArrayContent]::new($fileBytes)
$byteArrayContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/jpeg")

# Form data'ya ekle
$multipartContent.Add($byteArrayContent, "file", $fileName)

# İstek gönder (API key YOK)
$response = $httpClient.PostAsync($url, $multipartContent).Result
$responseContent = $response.Content.ReadAsStringAsync().Result

# Sonucu göster
$result = $responseContent | ConvertFrom-Json
Write-Host "Fotoğraf URL: $($result.url)" -ForegroundColor Green

# Temizlik
$httpClient.Dispose()
$multipartContent.Dispose()
$byteArrayContent.Dispose()
```

## 🌐 Tarayıcıdan Yükleme (HTML Form)

Basit bir HTML form ile de yükleyebilirsiniz:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Fotoğraf Yükle</title>
</head>
<body>
    <h1>Fotoğraf Yükle</h1>
    <form id="uploadForm">
        <input type="file" id="fileInput" accept="image/*" required>
        <button type="submit">Yükle</button>
    </form>
    <div id="result"></div>

    <script>
        document.getElementById('uploadForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const fileInput = document.getElementById('fileInput');
            const file = fileInput.files[0];
            
            if (!file) {
                alert('Lütfen bir dosya seçin');
                return;
            }
            
            const formData = new FormData();
            formData.append('file', file);
            
            try {
                const response = await fetch('https://fotougur.com.tr/api/upload', {
                    method: 'POST',
                    body: formData
                    // API key yok, header eklemiyoruz
                });
                
                const data = await response.json();
                
                if (data.success) {
                    document.getElementById('result').innerHTML = `
                        <h2>✅ Başarılı!</h2>
                        <p>Fotoğraf URL: <a href="${data.url}" target="_blank">${data.url}</a></p>
                        <img src="${data.url}" style="max-width: 500px;">
                    `;
                } else {
                    document.getElementById('result').innerHTML = `<p style="color: red;">Hata: ${data.error}</p>`;
                }
            } catch (error) {
                document.getElementById('result').innerHTML = `<p style="color: red;">Hata: ${error.message}</p>`;
            }
        });
    </script>
</body>
</html>
```

## 📱 JavaScript/Fetch ile

```javascript
async function uploadImage(file) {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await fetch('https://fotougur.com.tr/api/upload', {
        method: 'POST',
        body: formData
        // API key yok, header eklemiyoruz
    });
    
    const data = await response.json();
    
    if (data.success) {
        console.log('Fotoğraf URL:', data.url);
        return data.url;
    } else {
        console.error('Hata:', data.error);
        throw new Error(data.error);
    }
}

// Kullanım
const fileInput = document.querySelector('input[type="file"]');
fileInput.addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (file) {
        try {
            const url = await uploadImage(file);
            console.log('Yüklenen fotoğraf:', url);
        } catch (error) {
            console.error('Yükleme hatası:', error);
        }
    }
});
```

## 🔑 API Key Ne Zaman Gerekli?

API key **sadece** sunucudaki `.env` dosyasında `UPLOAD_API_KEY` tanımlıysa gerekir.

### API Key Tanımlıysa:

```powershell
# PowerShell script'inde
.\test-upload-working.ps1 -FilePath "resim.jpg" -ApiKey "your-api-key-here"
```

```javascript
// JavaScript'te
fetch('https://fotougur.com.tr/api/upload', {
    method: 'POST',
    headers: {
        'x-api-key': 'your-api-key-here'
    },
    body: formData
});
```

### API Key Tanımlı Değilse:

API key göndermenize gerek yok, direkt yükleyebilirsiniz!

## ✅ Başarılı Yükleme Sonrası

Yükleme başarılı olduğunda şu bilgileri alırsınız:

```json
{
  "success": true,
  "url": "https://fotougur.com.tr/uploads/1704643200000-abc123.jpg",
  "fileName": "1704643200000-abc123.jpg",
  "size": 1024000,
  "type": "image/jpeg",
  "message": "Fotoğraf başarıyla yüklendi"
}
```

**URL'yi kullanarak:**
- Tarayıcıda açabilirsiniz
- `<img>` tag'inde kullanabilirsiniz
- Başkalarıyla paylaşabilirsiniz

## 🧪 Hızlı Test

```powershell
# Windows PowerShell'de
cd "C:\Users\DELL\Desktop\premium foto"
.\test-upload-working.ps1 -FilePath "C:\Users\DELL\Desktop\resim.jpg"
```

**API key göndermiyoruz, direkt çalışır!**

