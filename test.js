import axios from 'axios';

// API Bilgileri
const supplierId = '406865';
const token = 'eUxhaGJMQWFPTVYxTEtuZDBEbXY6bWRwNkE2cTA2WDFCYWljZUFYVFc=';
const integrationRefCode = '7ccfaf9f-f24b-44e8-9041-7ed149ff1103';

// Test URL'leri
const testUrls = [
  {
    name: '📦 Ürünler (Products)',
    url: `https://apigw.trendyol.com/integration/sellers/${supplierId}/products?page=0&size=5`
  },
  {
    name: '🏷️ Markalar (Brands)',
    url: `https://apigw.trendyol.com/integration/sellers/brands?page=0&size=10`
  },
  {
    name: '📂 Kategoriler (Categories)',
    url: `https://apigw.trendyol.com/integration/sellers/categories`
  }
];

// Headers
const headers = {
  'Authorization': `Basic ${token}`,
  'Content-Type': 'application/json',
  'User-Agent': `${supplierId} - SelfIntegration`,
  'X-Integration-Reference-Code': integrationRefCode,
  'Accept': 'application/json',
  'Accept-Language': 'tr-TR,tr;q=0.9',
  'Cache-Control': 'no-cache'
};

console.log('🧪 Trendyol API Test (Farklı IP\'den)\n');
console.log('═══════════════════════════════════════════════════════');
console.log('📋 API Bilgileri:');
console.log('   Supplier ID:', supplierId);
console.log('   User-Agent:', headers['User-Agent']);
console.log('   Integration Ref Code:', integrationRefCode);
console.log('   IP Adresi:', 'Değişecek (VPN/Hotspot)');
console.log('═══════════════════════════════════════════════════════\n');

// IP adresini kontrol et
async function getMyIP() {
  try {
    const response = await axios.get('https://api.ipify.org?format=json', { timeout: 5000 });
    return response.data.ip;
  } catch (error) {
    return 'Bilinmiyor';
  }
}

// Test fonksiyonu
async function testEndpoint(name, url) {
  console.log(`\n🔍 Test: ${name}`);
  console.log(`   URL: ${url}`);
  
  try {
    const startTime = Date.now();
    const response = await axios.get(url, { 
      headers, 
      timeout: 15000,
      validateStatus: () => true // Tüm status kodlarını kabul et
    });
    const duration = Date.now() - startTime;
    
    if (response.status === 200) {
      console.log(`   ✅ BAŞARILI! (${response.status}) - ${duration}ms`);
      const data = response.data;
      if (data.content && Array.isArray(data.content)) {
        console.log(`   📊 Sonuç: ${data.content.length} adet kayıt bulundu`);
        if (data.totalElements) {
          console.log(`   📈 Toplam: ${data.totalElements} kayıt`);
        }
      } else if (Array.isArray(data)) {
        console.log(`   📊 Sonuç: ${data.length} adet kayıt bulundu`);
      } else {
        console.log(`   📊 Sonuç: ${JSON.stringify(data).substring(0, 100)}...`);
      }
      return true;
    } else if (response.status === 403) {
      console.log(`   ❌ FORBIDDEN (${response.status}) - Cloudflare engellemesi`);
      console.log(`   ⚠️  IP adresi bloklanmış olabilir`);
      return false;
    } else if (response.status === 401) {
      console.log(`   ❌ UNAUTHORIZED (${response.status}) - API Key/Token hatası`);
      return false;
    } else if (response.status === 556) {
      console.log(`   ❌ SERVICE UNAVAILABLE (${response.status}) - Cloudflare bloklaması`);
      console.log(`   ⚠️  IP adresi veya rate limiting`);
      return false;
    } else {
      console.log(`   ⚠️  Beklenmeyen durum: ${response.status}`);
      console.log(`   Response: ${JSON.stringify(response.data).substring(0, 200)}`);
      return false;
    }
  } catch (error) {
    if (error.code === 'ECONNABORTED') {
      console.log(`   ⏱️  TIMEOUT - İstek zaman aşımına uğradı`);
    } else if (error.response) {
      console.log(`   ❌ HATA: ${error.response.status} - ${error.response.statusText}`);
      if (error.response.data) {
        const data = typeof error.response.data === 'string' 
          ? error.response.data.substring(0, 200)
          : JSON.stringify(error.response.data).substring(0, 200);
        console.log(`   Detay: ${data}`);
      }
    } else {
      console.log(`   ❌ HATA: ${error.message}`);
    }
    return false;
  }
}

// Ana test fonksiyonu
async function runTests() {
  // IP adresini göster
  console.log('🌐 IP Adresi kontrol ediliyor...');
  const myIP = await getMyIP();
  console.log(`   Mevcut IP: ${myIP}\n`);
  
  if (myIP === 'Bilinmiyor') {
    console.log('⚠️  IP adresi alınamadı, test devam ediyor...\n');
  }
  
  console.log('═══════════════════════════════════════════════════════');
  console.log('🚀 API Testleri Başlatılıyor...');
  console.log('═══════════════════════════════════════════════════════');
  
  const results = [];
  
  for (const test of testUrls) {
    const success = await testEndpoint(test.name, test.url);
    results.push({ name: test.name, success });
    
    // Her test arasında kısa bir bekleme
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  // Özet
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('📊 TEST ÖZETİ');
  console.log('═══════════════════════════════════════════════════════');
  
  const successCount = results.filter(r => r.success).length;
  const totalCount = results.length;
  
  results.forEach(result => {
    const icon = result.success ? '✅' : '❌';
    console.log(`${icon} ${result.name}`);
  });
  
  console.log(`\n📈 Başarı Oranı: ${successCount}/${totalCount} (${Math.round(successCount/totalCount*100)}%)`);
  
  if (successCount === 0) {
    console.log('\n⚠️  Tüm testler başarısız!');
    console.log('💡 Öneriler:');
    console.log('   1. VPN kullanarak farklı bir IP deneyin');
    console.log('   2. Mobil hotspot ile farklı bir network deneyin');
    console.log('   3. Trendyol desteğine IP whitelist için başvurun');
    console.log('   4. API credentials\'ların doğru olduğundan emin olun');
  } else if (successCount < totalCount) {
    console.log('\n⚠️  Bazı testler başarısız oldu');
    console.log('💡 Başarısız endpoint\'ler için IP bloklaması olabilir');
  } else {
    console.log('\n🎉 Tüm testler başarılı! API çalışıyor.');
  }
  
  console.log('\n═══════════════════════════════════════════════════════\n');
}

// Script'i çalıştır
runTests().catch(error => {
  console.error('❌ Kritik Hata:', error);
  process.exit(1);
});

