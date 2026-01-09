# 🔒 Şifreli Galeri Sayfası

## 📍 Sayfa Adresi

**URL:** `https://fotougur.com.tr/galeri`

**Şifre:** `oxelio2024`

## ✨ Özellikler

- ✅ Şifre korumalı giriş (localStorage ile hatırlama)
- ✅ Grid layout ile fotoğraf gösterimi
- ✅ Responsive tasarım (mobil uyumlu)
- ✅ Fotoğrafa tıklayınca büyük görünüm (modal)
- ✅ Otomatik fotoğraf listeleme
- ✅ En yeni fotoğraflar önce gösterilir

## 🎨 Kullanım

1. **Sayfaya Git:**
   ```
   https://fotougur.com.tr/galeri
   ```

2. **Şifre Gir:**
   - Şifre: `oxelio2024`
   - Şifre doğruysa localStorage'a kaydedilir (tekrar giriş gerekmez)

3. **Fotoğrafları Görüntüle:**
   - Tüm yüklenen fotoğraflar grid şeklinde gösterilir
   - Fotoğrafa tıklayınca büyük görünüm açılır
   - Modal'dan çıkmak için X butonuna tıklayın veya dışarı tıklayın

4. **Çıkış:**
   - Sağ üstteki "Çıkış" butonuna tıklayın

## 📁 Oluşturulan Dosyalar

1. **`app/(public)/galeri/page.tsx`** - Galeri sayfası (şifre korumalı)
2. **`app/api/uploads/list/route.ts`** - Fotoğraf listesi API endpoint'i

## 🔧 Teknik Detaylar

### Şifre Kontrolü
- Şifre: `oxelio2024` (kod içinde sabit)
- localStorage ile hatırlama
- Şifre yanlışsa hata mesajı gösterilir

### Fotoğraf Listeleme
- `public/uploads` klasöründeki tüm resimler listelenir
- Desteklenen formatlar: jpg, jpeg, png, gif, webp, svg
- En yeni fotoğraflar önce gösterilir (timestamp'e göre)

### Grid Layout
- Mobil: 2 sütun
- Tablet: 3-4 sütun
- Desktop: 5 sütun
- Hover efekti ile büyütme animasyonu

### Modal (Büyük Görünüm)
- Tıklanan fotoğraf tam ekran gösterilir
- Karanlık arka plan
- X butonu ile kapatma
- Dışarı tıklayarak kapatma

## 🚀 Deploy

```bash
# Git commit
git add app/(public)/galeri/page.tsx app/api/uploads/list/route.ts
git commit -m "Add password-protected gallery page"
git push

# Sunucuda
cd ~/premiumfoto
git pull
npm run build
pm2 restart foto-ugur-app
```

## 🔐 Şifre Değiştirme

Şifreyi değiştirmek için `app/(public)/galeri/page.tsx` dosyasında:

```typescript
if (password === 'oxelio2024') {  // Burayı değiştirin
  // ...
}
```

ve

```typescript
if (savedAuth === 'oxelio2024') {  // Burayı da değiştirin
  // ...
}
```

## 📱 Responsive

- **Mobil (< 640px):** 2 sütun
- **Tablet (640px - 1024px):** 3-4 sütun
- **Desktop (> 1024px):** 5 sütun

## 🎯 Özelleştirme

### Grid Sütun Sayısını Değiştirme

`app/(public)/galeri/page.tsx` dosyasında:

```tsx
<div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
```

- `grid-cols-2`: Mobil (2 sütun)
- `sm:grid-cols-3`: Küçük ekranlar (3 sütun)
- `md:grid-cols-4`: Orta ekranlar (4 sütun)
- `lg:grid-cols-5`: Büyük ekranlar (5 sütun)

### Renkleri Değiştirme

Tailwind CSS class'larını değiştirerek renkleri özelleştirebilirsiniz.

---

**Sayfa Hazır!** 🎉

Artık `https://fotougur.com.tr/galeri` adresinden şifreli galeri sayfasına erişebilirsiniz.

