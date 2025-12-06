# Sitemap Submit Script Düzeltmesi

## Sorun

Script çalıştırıldığında JSON parse hatası alınıyordu:
```
Error submitting sitemap: SyntaxError: Unexpected token '<', "<!DOCTYPE "... is not valid JSON
```

## Çözüm

1. **Response handling düzeltildi**: Response body'yi önce text olarak okuyup sonra JSON.parse() yapıyoruz
2. **Hata mesajları iyileştirildi**: Daha detaylı hata mesajları eklendi
3. **Debug bilgileri eklendi**: Hangi URL'ye istek yapıldığı gösteriliyor

## Kullanım

```bash
# .env dosyasında token tanımlı olmalı
SITEMAP_SUBMIT_TOKEN=your-secret-token-here

# Script'i çalıştır
npm run submit-sitemap
```

## Notlar

- Script, `NEXT_PUBLIC_SITE_URLS` veya `NEXT_PUBLIC_SITE_URL` environment variable'ını kullanır
- İlk domain'i kullanır (çoklu domain durumunda)
- Token kontrolü yapılır (GET isteği için)

