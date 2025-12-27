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

## Adımlar Özeti (16 Adım)

1. AWS EC2 instance oluştur
2. SSH ile bağlan
3. Sistem güncellemesi
4. Docker kur
5. Repository clone et
6. .env dosyası düzenle
7. Container'ları başlat
8. Migration çalıştır
9. Uygulama key oluştur
10. Storage link oluştur
11. Cache'leri oluştur
12. Instance actor oluştur
13. Package discovery & Horizon
14. Final cache rebuild
15. Admin kullanıcı oluştur
16. Web testi

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

- yum update ile sistemş güncelle
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

PixelFed kurulum dosyaları, docker-compose.yaml ve .env.docker şablonu bu repo'da hazır.

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
- KURULUM.md (detaylı kurulum rehberi)

### Başarı Kriterleri

- [ ] Repo klonlandı
- [ ] compose.yaml ve .env.docker mevcut

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

## Adım 8: Migration Çalıştır

### Ne Yapacaksın?

Veritabanı tablolarını oluşturacaksın.

### Migration Nedir?

Laravel'in veritabanı şemasını versiyonlama sistemi. Migration dosyaları `CREATE TABLE` komutlarını içerir. Her migration bir veritabanı değişikliğini temsil eder.

### Neden Gerekli?

PixelFed 240+ tablo kullanıyor:
- users (kullanıcılar)
- statuses (gönderiler)
- followers (takipçiler)
- likes, comments vs.

Migration'lar bunları otomatik oluşturur.

### Nasıl?

- web container'a gir
- php artisan migrate --force çalıştır
- 1-2 dakika bekle

### Beklenen Çıktı

```
INFO  Running migrations.
  2018_04_03_125338_create_stories_table .... DONE
  2018_04_19_054343_add_remote_url_to_profiles .... DONE
  ...
```

### Başarı Kriterleri

- [ ] Migration tamamlandı
- [ ] 240+ tablo oluşturuldu
- [ ] Hata mesajı yok

---

## Adım 9: Uygulama Key Oluştur

### Ne Yapacaksın?

Laravel application key oluşturacaksın.

### Neden?

Laravel şifreleme, session ve token'ları bu key ile güvenli hale getirir. Her kurulum unique key kullanmalı.

### Nasıl?

php artisan key:generate çalıştır.

### Beklenen Çıktı

```
Application key set successfully.
```

### Başarı Kriterleri

- [ ] Key oluşturuldu
- [ ] .env dosyasında APP_KEY değeri var

---

## Adım 10: Storage Link Oluştur

### Ne Yapacaksın?

Public storage için symlink oluşturacaksın.

### Neden?

Kullanıcıların yüklediği fotoğraflar /storage/app/public'te saklanır. Web'den erişilebilmesi için /public/storage'a symlink gerekir.

### Symlink Nedir?

Windows'taki "shortcut" gibi. Bir klasöre başka yerden erişim sağlar.

### Nasıl?

php artisan storage:link çalıştır.

### Başarı Kriterleri

- [ ] Symlink oluşturuldu
- [ ] Fotoğraflar web'den erişilebilir olacak

---

## Adım 11: Cache Oluştur

### Ne Yapacaksın?

Config, route ve view cache'lerini oluşturacaksın.

### Neden?

Laravel her istekte .env ve route dosyalarını okuyor. Cache'lemek performansı 10x artırır.

**Cache Tipleri:**
- **config:** Environment değişkenleri
- **route:** URL route'ları
- **view:** Blade template'leri

### Nasıl?

3 artisan komutu çalıştır:
- config:cache
- route:cache
- view:cache

### Başarı Kriterleri

- [ ] 3 cache oluşturuldu
- [ ] Uygulama hızlı açılacak

---

## Adım 12: Instance Actor Oluştur

### Ne Yapacaksın?

PixelFed instance actor'unu oluşturacaksın.

### Neden?

ActivityPub federation protokolü için instance'ın kendi "kullanıcısı" olmalı. Diğer instance'larla iletişimde bu actor kullanılır.

### ActivityPub Nedir?

Mastodon, PixelFed gibi platformların birbirleriyle konuşma protokolü. E-mail gibi, farklı servislerde olsan da mesajlaşabiliyorsun.

### Nasıl?

php artisan instance:actor çalıştır.

### Başarı Kriterleri

- [ ] Instance actor oluşturuldu
- [ ] Federation hazır

---

## Adım 13: Package Discovery & Horizon

### Ne Yapacaksın?

Laravel paketlerini discover edip Horizon'u kuracaksın.

### Package Discovery Nedir?

Laravel composer paketlerinin provider'larını otomatik keşfetme. Manuel registration gerekmez.

### Horizon Nedir?

Redis queue işlerini monitör eden dashboard. Background job'ları izleyebilirsin.

### Nasıl?

2 komut çalıştır:
- package:discover
- horizon:install

### Başarı Kriterleri

- [ ] Paketler discover edildi
- [ ] Horizon kuruldu

---

## Adım 14: Final Cache Rebuild

### Ne Yapacaksın?

Route cache'ini rebuild edip container'ı restart edeceksin.

### Neden?

Yeni route'lar (Horizon vs.) eklendi, cache'i yenilemek gerekiyor.

### Nasıl?

- route:cache tekrar çalıştır
- docker-compose restart web
- 3 saniye bekle

### Başarı Kriterleri

- [ ] Cache rebuild edildi
- [ ] Container restart oldu

---

## Adım 15: Admin Kullanıcı Oluştur

### Ne Yapacaksın?

İlk kullanıcıyı (admin) oluşturacaksın.

### Neden?

PixelFed'e login olabilmek için kullanıcı lazım. İlk kullanıcı admin olacak.

### Nasıl?

- php artisan user:create çalıştır
- Sırayla bilgileri gir:
  - Username: admin
  - Email: admin@pixelfed.local
  - Name: Admin User
  - Password: (güçlü şifre - görünmez)
  - Make admin: yes

### Başarı Kriterleri

- [ ] Kullanıcı oluşturuldu
- [ ] Admin yetkisi var
- [ ] Şifre kaydedildi (unutma!)

---

## Adım 16: Web Test

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

### 404 Hatası - Ana Sayfa Yüklenmiyor

**Muhtemel sebep:** APP_DOMAIN'de port var!

**Kontrol et:**
- APP_DOMAIN="54.221.128.45" ← DOĞRU (port yok)
- APP_DOMAIN="54.221.128.45:8080" ← YANLIŞ!

**Çözüm:**
- .env dosyasını düzelt
- config:cache tekrar çalıştır
- Container'ı restart et

### Container Başlamıyor

**Kontrol et:**
- docker-compose logs ile hata logu oku
- DB şifresi .env'de doğru mu?
- Port 8080 başka uygulama tarafından kullanılıyor mu?

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
- [ ] Migration tamamlandı çıktısı
- [ ] Ana sayfa tarayıcıda açık (URL görünür)
- [ ] Login sonrası timeline

### 2. Rapor (PDF)

**İçerik:**
- Kullandığın AWS region
- EC2 Public IP
- Karşılaştığın hatalar ve çözümleri
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

### ⭐ 80 Puan - Migration & Admin
- Migration tamamlandı
- Admin kullanıcı oluşturuldu
- Database'de kullanıcı var

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
2. Hata logu oku, Google'la ara
3. .env dosyasını backup'la
4. Admin şifresini unutma!
5. Migration 2 dakika sürebilir, sabırlı ol

### 📚 Öğreneceklerın

- AWS EC2 yönetimi
- Docker & Docker Compose
- Laravel framework
- Database migration
- Linux komut satırı
- Networking (port, security group)
- Troubleshooting skills

---

## Başarılar! 🚀

Bu proje sonunda production-ready bir web uygulamasını sıfırdan deploy edebilecek seviyeye gelmiş olacaksın. Gerçek dünya DevOps operasyonlarının çoğunu deneyimleyeceksin.
