# STUDENT ROADMAP - PixelFed Docker Kurulum Projesi

## Görev Tanımı

AWS bulut platformunda Docker kullanarak **PixelFed** (Instagram benzeri açık kaynak sosyal medya) kuracaksınız.

**Hedef:** `http://SUNUCU-IP:8080` adresinde çalışan PixelFed instance'ı

**Teslim:** Screenshot + rapor

---

## Gereksinimler

- AWS hesabı (öğrenci hesabı yeterli)
- Temel Linux bilgisi
- Docker konseptlerini biliyor olmak
- SSH kullanabilmek

---

## Adımlar Özeti (10 Adım)

1. AWS EC2 instance oluştur
2. SSH ile bağlan
3. Sistem güncellemesi
4. Docker kur
5. Repository clone et
6. .env dosyası düzenle
7. Container'ları başlat
8. **Kurulum script'i çalıştır** ← OTOMATİK!
9. Admin kullanıcı oluştur
10. Web testi

---

## Adım 1: AWS EC2 Instance Oluştur

### Ne Yapacaksın?

Amazon Web Services'te bir Linux sunucusu kiralayacaksın.

### Neden?

PixelFed web uygulaması çalıştırmak için 7/24 açık bir sunucuya ihtiyacın var. Kendi bilgisayarını kapatınca uygulama da kapanır, AWS sunucusu sürekli çalışır.

### Nasıl?

**AWS Console → EC2 → Launch Instance**

**Yapılacaklar:**
- İsim: `pixelfed-server`
- AMI: Amazon Linux 2023
- Instance type: t2.medium (2 vCPU, 4 GB RAM)
- Key pair oluştur ve indir (.pem dosyası)
- Security Group: Port 22 (SSH) ve 8080 (PixelFed) aç

### Başarı Kriterleri

- [ ] Instance "Running" durumunda
- [ ] Public IP var
- [ ] .pem dosyası indirildi

---

## Adım 2: SSH Bağlantısı

### Ne Yapacaksın?

Sunucuya terminal üzerinden bağlanacaksın.

### Neden?

Sunucuya komut göndermek için terminalden erişmen gerekiyor. GUI yok, her şey komut satırından.

### Nasıl?

- .pem dosyasına izin ver (chmod 400)
- SSH komutuyla bağlan
- Kullanıcı: ec2-user

### Başarı Kriterleri

- [ ] SSH bağlantısı başarılı
- [ ] Prompt'ta "ec2-user@ip" görünüyor

---

## Adım 3: Sistem Güncellemesi

### Ne Yapacaksın?

Sunucudaki paketleri güncelleyeceksin.

### Neden?

Güvenlik yamaları ve en güncel paketler için. Eski paketler hata verebilir.

### Nasıl?

- yum update ile sistemi güncelle
- curl ve git gibi gerekli araçları kur

### Başarı Kriterleri

- [ ] Paket güncellemesi tamamlandı
- [ ] curl ve git kurulu

---

## Adım 4: Docker Kurulumu

### Ne Yapacaksın?

Docker ve Docker Compose'u kuracaksın.

### Neden?

PixelFed birden fazla servisten oluşuyor (web, database, redis, worker). Docker ile hepsini container olarak izole şekilde çalıştırıyorsun.

### Docker Nedir?

Uygulama ve bağımlılıklarını paketleyen konteyner teknolojisi. Her konteyner kendi dünyasında çalışır.

### Docker Compose Nedir?

Birden fazla container'ı tek komutla yöneten araç. Bizim projede 4+ container var.

### Nasıl?

- Docker'ı yum ile kur
- Docker servisini başlat ve enable et
- Kullanıcıyı docker grubuna ekle
- Docker Compose binary'sini GitHub'dan indir

### Başarı Kriterleri

- [ ] docker --version çalışıyor
- [ ] docker-compose --version çalışıyor
- [ ] Docker servisi çalışıyor

---

## Adım 5: Repository Clone

### Ne Yapacaksın?

Eğitmenin hazırladığı GitHub repository'sini klonlayacaksın.

### Neden?

PixelFed kurulum dosyaları, docker-compose.yaml ve .env.docker şablonu bu repo'da hazır. **Ayrıca otomatik kurulum scripti de var!**

### Repository Adresi

```
https://github.com/mahmutdemirtr/Pixcelfed.git
```

### Nasıl?

- Home dizininde git clone çalıştır
- pixelfed klasörüne gir
- Dosyaları kontrol et

### Görmesi Gerekenler

- compose.yaml (Docker servislerinin tarifi)
- .env.docker (environment şablonu)
- **setup-pixelfed.sh** ← OTOMATİK KURULUM SCRIPT!
- KURULUM.md (detaylı kurulum rehberi)

### Başarı Kriterleri

- [ ] Repo klonlandı
- [ ] compose.yaml ve .env.docker mevcut
- [ ] setup-pixelfed.sh mevcut

---

## Adım 6: .env Dosyası Düzenleme

### Ne Yapacaksın?

Environment değişkenlerini düzenleyeceksin.

### Neden?

PixelFed'e kendi sunucu IP'ni, database şifreni vs. bildirmen gerekiyor. Her kurulum farklı ayarlar kullanır.

### .env Nedir?

Laravel framework'ünün konfigürasyon dosyası. Database, mail, cache ayarları burada.

### Düzenlenecek 5 Alan

**1. APP_NAME** (Satır 24)
- Uygulamanın ismi
- Örnek: "PixelFed"

**2. APP_DOMAIN** (Satır 32)
- **SADECE** sunucu IP (PORT OLMADAN!)
- Örnek: "54.221.128.45"
- **Nereden bulacağın:** AWS Console → EC2 → Public IPv4
- **⚠️ KRİTİK:** `:8080` ekleme! Port sadece APP_URL'de olacak

**3. APP_URL** (Satır 41)
- Tam URL
- Örnek: "http://54.221.128.45:8080"
- **Dikkat:** `http://` (https değil!)

**4. INSTANCE_CONTACT_EMAIL** (Satır 248)
- İletişim emaili
- Örnek: "admin@pixelfed.local"

**5. DB_PASSWORD** (Satır 538)
- Veritabanı şifresi
- **Güçlü bir şifre belirle!**
- Örnek: "PixelFed2025_Secure!"

### Nasıl Düzenlenir?

- .env.docker'ı .env'e kopyala
- nano veya vim ile aç
- Ctrl+W ile ara ve değiştir
- Ctrl+O ile kaydet

### Başarı Kriterleri

- [ ] .env dosyası oluştu
- [ ] 5 alan doğru dolduruldu
- [ ] APP_DOMAIN'de PORT YOK!
- [ ] Kendi IP adresi kullanıldı

---

## Adım 7: Container'ları Başlat

### Ne Yapacaksın?

Docker Compose ile tüm servisleri başlatacaksın.

### Neden?

PixelFed tek bir uygulama değil, birden fazla servisin orkestrasyonu:
- **web:** Apache + PHP
- **worker:** Background jobs
- **db:** MariaDB database
- **redis:** Cache

### Nasıl?

- docker-compose up -d komutuyla başlat
- -d: detached mode (arka planda çalışsın)
- 2-3 dakika bekle (ilk başlatma uzun)

### Durum Kontrolü

docker-compose ps ile kontrol et.

**Görmesi gerekenler:**
- pixelfed-web: Up
- pixelfed-worker: Up
- pixelfed-db: Up
- pixelfed-redis: Up

### Başarı Kriterleri

- [ ] Tüm container'lar "Up" durumunda
- [ ] Hata logu yok

---

## Adım 8: Otomatik Kurulum Script ⚡

### Ne Yapacaksın?

Hazır kurulum script'ini çalıştıracaksın.

### Neden?

Migration, cache, key generation gibi 7 teknik adım var. Bunları manuel yapmak hem zor hem hata yapmaya açık. Script hepsini otomatik yapıyor.

### Script Ne Yapar? (Arka Planda)

Script otomatik olarak şunları yapar:

1. **Migration:** Veritabanı tablolarını oluşturur (240+ tablo)
2. **Key Generate:** Laravel application key'i üretir
3. **Storage Link:** Fotoğraflar için symlink oluşturur
4. **Cache:** Config, route ve view cache'lerini oluşturur
5. **Instance Actor:** ActivityPub için instance actor'u oluşturur
6. **Package Discovery:** Laravel paketlerini discover eder
7. **Horizon:** Queue monitoring aracını kurar
8. **Final Rebuild:** Final cache rebuild ve container restart

### Migration Nedir?

Laravel'in veritabanı şemasını versiyonlama sistemi. Migration dosyaları `CREATE TABLE` komutlarını içerir. PixelFed 240+ tablo kullanıyor (users, posts, likes, followers vs.).

### ActivityPub Nedir?

Mastodon, PixelFed gibi platformların birbirleriyle konuşma protokolü. E-mail gibi, farklı servislerde olsan da mesajlaşabiliyorsun.

### Horizon Nedir?

Redis queue işlerini monitör eden dashboard. Background job'ları izleyebilirsin.

### Nasıl Çalıştırılır?

Tek komut:
```bash
./setup-pixelfed.sh
```

### Beklenen Çıktı

```
=========================================
PixelFed Kurulum Scripti Başlatılıyor...
=========================================

[⏳] Container durumu kontrol ediliyor...
[✓] Container'lar çalışıyor

[⏳] Adım 1/8: Veritabanı migration'ları çalıştırılıyor...
           (Bu adım 1-2 dakika sürebilir, lütfen bekleyin...)
[✓] Migration tamamlandı! (240+ tablo oluşturuldu)

[⏳] Adım 2/8: Laravel application key oluşturuluyor...
[✓] Application key oluşturuldu

[⏳] Adım 3/8: Storage symlink oluşturuluyor...
[✓] Storage link oluşturuldu

[⏳] Adım 4/8: Cache'ler oluşturuluyor...
           → Config cache...
           → Route cache...
           → View cache...
[✓] Tüm cache'ler oluşturuldu (config, route, view)

[⏳] Adım 5/8: Instance actor oluşturuluyor...
[✓] Instance actor oluşturuldu

[⏳] Adım 6/8: Laravel paketleri discover ediliyor...
[✓] Paketler discover edildi

[⏳] Adım 7/8: Horizon kurulumu yapılıyor...
[✓] Horizon kuruldu

[⏳] Adım 8/8: Final cache rebuild ve container restart...
           → Route cache yeniden oluşturuluyor...
           → Web container restart ediliyor...
           → Container'ın hazır olması bekleniyor...
[✓] Cache rebuild ve restart tamamlandı

=========================================
✓ KURULUM TAMAMLANDI!
=========================================

Sıradaki adımlar:
1. Admin kullanıcı oluştur:
   sudo docker-compose exec web php artisan user:create

2. Tarayıcıda aç:
   http://54.221.128.45:8080

İyi çalışmalar! 🚀
```

### Süre

~2-3 dakika (migration en uzun adım)

### Başarı Kriterleri

- [ ] Script hatasız çalıştı
- [ ] "✓ KURULUM TAMAMLANDI!" mesajı geldi
- [ ] 8 adımın hepsi "✓" aldı
- [ ] Hata mesajı yok

---

## Adım 9: Admin Kullanıcı Oluştur

### Ne Yapacaksın?

İlk kullanıcıyı (admin) oluşturacaksın.

### Neden?

PixelFed'e login olabilmek için kullanıcı lazım. İlk kullanıcı admin olacak.

### Nasıl?

Tek komut:
```bash
sudo docker-compose exec web php artisan user:create
```

### Girmen Gerekenler

Script sana sırayla soracak:
```
Username: admin
Email: admin@pixelfed.local
Name: Admin User
Password: (güçlü şifre - görünmez)
Confirm Password: (aynı şifre)
Make this user an admin? (yes/no): yes
Confirm user creation? (yes/no): yes
```

### Başarı Kriterleri

- [ ] Kullanıcı oluşturuldu
- [ ] "Created new user!" mesajı geldi
- [ ] Admin yetkisi var
- [ ] Şifre kaydedildi (unutma!)

---

## Adım 10: Web Test

### Ne Yapacaksın?

Tarayıcıdan PixelFed'e erişeceksin.

### Nasıl?

**Tarayıcıda aç:**
```
http://<SENIN_IP>:8080
```

### Ana Sayfa Testi

**Görmesi gerekenler:**
- ✅ PixelFed logosu
- ✅ "Login" butonu
- ✅ "Discover", "About" linkleri
- ❌ 404 hatası OLMAMALI!

### Login Testi

- Login butonuna tıkla
- Username ve password gir
- Login ol

**Login sonrası:**
- ✅ Timeline yüklenmeli
- ✅ Sol menüde "Home", "Discover", "Groups" olmalı
- ✅ Profil fotoğrafı yükleyebilmelisin

### Başarı Kriterleri

- [ ] Ana sayfa açılıyor (404 yok!)
- [ ] Login başarılı
- [ ] Timeline görüntüleniyor
- [ ] Fotoğraf yükleyebiliyorsun

---

## Sorun Giderme

### Script Hata Veriyor

**Container çalışmıyor:**
```bash
sudo docker-compose ps  # Kontrol et
sudo docker-compose up -d  # Tekrar başlat
./setup-pixelfed.sh  # Script'i tekrar çalıştır
```

**Logları kontrol et:**
```bash
sudo docker-compose logs web --tail=50
sudo docker-compose logs db --tail=50
```

### 404 Hatası - Ana Sayfa Yüklenmiyor

**Muhtemel sebep:** APP_DOMAIN'de port var!

**Kontrol et:**
- APP_DOMAIN="54.221.128.45" ← DOĞRU (port yok)
- APP_DOMAIN="54.221.128.45:8080" ← YANLIŞ!

**Çözüm:**
- .env dosyasını düzelt
- Script'i tekrar çalıştır: `./setup-pixelfed.sh`

### Port 8080'e Erişilemiyor

**Kontrol et:**
- AWS Security Group'ta port 8080 açık mı?
- Inbound Rules kontrol et
- Source: 0.0.0.0/0 olmalı

### Migration Hatası

**Muhtemel sebep:** Database bağlantısı yok

**Kontrol et:**
- pixelfed-db container çalışıyor mu?
- DB_HOST=db olmalı (.env'de)
- DB_PASSWORD doğru mu?

---

## Teslim Edilecekler

### 1. Screenshot'lar

- [ ] EC2 instance Running durumunda
- [ ] docker-compose ps çıktısı (tüm container'lar Up)
- [ ] Script başarıyla çalıştı ("✓ KURULUM TAMAMLANDI!")
- [ ] Ana sayfa tarayıcıda açık (URL görünür)
- [ ] Login sonrası timeline

### 2. Rapor (PDF)

**İçerik:**
- Kullandığın AWS region
- EC2 Public IP
- Karşılaştığın hatalar ve çözümleri
- **Script'in ne yaptığını açıklama** (8 adım)
- Migration'ın ne olduğunu açıklama
- Docker Compose'un neden gerekli olduğunu açıklama

---

## Puanlama

### ⭐ 60 Puan - Temel Kurulum
- EC2 oluşturuldu
- Docker kuruldu
- Repository klonlandı
- .env düzenlendi
- Container'lar çalışıyor

### ⭐ 80 Puan - Script Başarılı
- **setup-pixelfed.sh başarıyla çalıştı**
- Migration tamamlandı
- Admin kullanıcı oluşturuldu

### ⭐ 100 Puan - Çalışan Uygulama
- Web arayüzüne erişiliyor
- Login başarılı
- Timeline yükleniyor
- **404 hatası yok!**

---

## Önemli Notlar

### ⚠️ En Sık Yapılan Hata

**APP_DOMAIN'e port ekleme!**

❌ Yanlış: `APP_DOMAIN="54.221.128.45:8080"`
✅ Doğru: `APP_DOMAIN="54.221.128.45"`

Port **sadece** APP_URL'de olmalı!

### 💡 İpuçları

1. Her adımdan sonra kontrol et, ilerle
2. Script hata verirse logu oku
3. .env dosyasını backup'la
4. Admin şifresini unutma!
5. Script 2-3 dakika sürebilir, sabırlı ol

### 📚 Öğreneceklerin

- AWS EC2 yönetimi
- Docker & Docker Compose
- **Automation (script yazma ve kullanma)**
- Laravel framework (migration, cache, artisan)
- Database migration konsepti
- Linux komut satırı
- Networking (port, security group)
- Troubleshooting skills

### 🎯 Script'in Avantajları

- ✅ Manuel hata riski yok
- ✅ Tüm adımlar otomatik
- ✅ Tutarlı sonuç
- ✅ Zaman tasarrufu
- ✅ Production-ready yaklaşım

**Gerçek dünyada:** Deployment scriptleri böyle çalışır. DevOps mühendisleri manuel kurulum yapmaz, her şeyi otomatikleştirir!

---

## Başarılar! 🚀

Bu proje sonunda:
- ✅ Production-ready bir web uygulamasını deploy edebileceksin
- ✅ Docker orchestration yapabileceksin
- ✅ Automation scriptlerini kullanabileceksin
- ✅ AWS EC2'yi yönetebileceksin
- ✅ DevOps operasyonlarını deneyimlemiş olacaksın

**10 adımda PixelFed kurulumu - Script sayesinde kolay!**
