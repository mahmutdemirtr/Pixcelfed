# PixelFed Kurulum - Eğitmen Çözüm Rehberi

## Adım 1: AWS EC2 Oluşturma

### AWS Console

```
URL: https://console.aws.amazon.com/
Services → EC2 → Launch Instance
```

### Instance Ayarları

**Name:**
```
pixelfed-server
```

**AMI:**
- Amazon Linux 2023 (64-bit x86)

**Instance type:**
- t2.medium

**Key pair:**
- Create new key pair
- Name: `pixelfed-key`
- Type: RSA
- Format: .pem
- Download

**Security Group:**
- Create new: `pixelfed-security-group`

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | 0.0.0.0/0 | SSH access |
| HTTP | TCP | 80 | 0.0.0.0/0 | HTTP |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 | PixelFed |


**Launch ve Public IP not al**

---

## Adım 2: SSH Bağlantısı

### SSH ile Bağlan

```bash
chmod 400 pixelfed-key.pem
ssh -i pixelfed-key.pem ec2-user@<PUBLIC_IP>
```

---

## Adım 3: Sistem Güncellemesi

### Paket Listesini Güncelle

```bash
sudo yum update -y
```

### Gerekli Araçları Kur

```bash
sudo yum install -y curl git
```

---

## Adım 4: Docker Kurulumu

### Docker Kur

```bash
sudo yum install -y docker
```

### Docker Servisini Başlat

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Kullanıcıyı Docker Grubuna Ekle

```bash
sudo usermod -aG docker ec2-user
```

### Docker Compose Kur

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Test

```bash
docker --version
docker-compose --version
```

---

## Adım 5: PixelFed Repository Klonla

### Repository Klonla

```bash
cd ~
git clone https://github.com/mahmutdemirtr/Pixcelfed.git pixelfed
cd pixelfed
```

### Dosyaları Kontrol Et

```bash
ls -la
```

**Görmesi gerekenler:**
- compose.yaml
- .env.docker
- setup-pixelfed.sh ← **KURULUM SCRIPT**
- KURULUM.md

---

## Adım 6: .env Dosyası Oluşturma ve Düzenleme

```bash
cp .env.docker .env
curl -s http://checkip.amazonaws.com  # Public IP'yi öğren
nano .env
```

### Düzenlenecek 5 Alan (Ctrl+W ile ara):

**1. APP_NAME (Satır 24):**
```bash
APP_NAME="PixelFed"
```

**2. APP_DOMAIN (Satır 32) - ⚠️ KRİTİK: PORT OLMADAN!**
```bash
APP_DOMAIN="<EC2_PUBLIC_IP>"
```
Örnek: `APP_DOMAIN="54.221.128.45"` (PORT YOK!)

**3. APP_URL (Satır 41):**
```bash
APP_URL="http://<EC2_PUBLIC_IP>:8080"
```
Örnek: `APP_URL="http://54.221.128.45:8080"`

**4. INSTANCE_CONTACT_EMAIL (Satır 248):**
```bash
INSTANCE_CONTACT_EMAIL="admin@pixelfed.local"
```

**5. DB_PASSWORD (Satır 538):**
```bash
DB_PASSWORD="PixelFed2025_Secure!"
```

### Kaydet ve Çık

```
Ctrl+O  → Kaydet
Enter   → Onayla
Ctrl+X  → Çık
```

### Kontrol Et

```bash
grep -E "^APP_NAME=|^APP_DOMAIN=|^APP_URL=|^INSTANCE_CONTACT_EMAIL=|^DB_PASSWORD=" .env
```

**Beklenen çıktı:**
```
APP_NAME="PixelFed"
APP_DOMAIN="54.221.128.45"
APP_URL="http://54.221.128.45:8080"
INSTANCE_CONTACT_EMAIL="admin@pixelfed.local"
DB_PASSWORD="PixelFed2025_Secure!"
```

---

## Adım 7: Konteynerleri Başlat

```bash
sudo docker-compose up -d
```

**İlk çalıştırma 2-3 dakika sürer.**

### Durum Kontrolü

```bash
sudo docker-compose ps
```

**Tüm servisler "Up" olmalı:**
- pixelfed-web
- pixelfed-worker
- pixelfed-db
- pixelfed-redis

---

## Adım 8: Otomatik Kurulum Script

### Script'i Çalıştır

```bash
./setup-pixelfed.sh
```

**Bu script otomatik olarak yapar:**
1. ✅ Veritabanı migration (240+ tablo)
2. ✅ Laravel application key oluşturma
3. ✅ Storage symlink oluşturma
4. ✅ Cache'leri oluşturma (config, route, view)
5. ✅ Instance actor oluşturma
6. ✅ Package discovery
7. ✅ Horizon kurulumu
8. ✅ Final cache rebuild ve restart

**Süre:** ~2-3 dakika

### Beklenen Çıktı

```
=========================================
PixelFed Kurulum Scripti Başlatılıyor...
=========================================

[⏳] Container durumu kontrol ediliyor...
[✓] Container'lar çalışıyor

[⏳] Adım 1/8: Veritabanı migration'ları çalıştırılıyor...
[✓] Migration tamamlandı! (240+ tablo oluşturuldu)

[⏳] Adım 2/8: Laravel application key oluşturuluyor...
[✓] Application key oluşturuldu

...

=========================================
✓ KURULUM TAMAMLANDI!
=========================================
```

---

## Adım 9: Admin Kullanıcı Oluştur

```bash
sudo docker-compose exec web php artisan user:create
```

**Sırayla girilecekler:**
```
Username: admin
Email: admin@pixelfed.local
Name: Admin User
Password: Admin2025!
Confirm Password: Admin2025!
Make this user an admin? (yes/no): yes
Confirm user creation? (yes/no): yes
```

**Başarılı çıktı:**
```
Created new user!
```

---

## Adım 10: Web Test

### Tarayıcıda Aç

```
http://<EC2_PUBLIC_IP>:8080
```

Örnek: `http://54.221.128.45:8080`

### Ana Sayfa Test

- ✅ Sayfa yüklenmeli (404 OLMAMALI!)
- ✅ PixelFed logosu görünmeli
- ✅ Sağ üstte "Login" butonu olmalı

### Login Test

```
Username: admin
Password: Admin2025!
```

- ✅ Login başarılı olmalı
- ✅ Timeline görüntülenmeli
- ✅ Sol menüde "Discover", "Groups" vs. olmalı

---

## Sorun Giderme

### Script Hata Veriyor

**Container çalışmıyor:**
```bash
sudo docker-compose ps  # Tüm container'lar Up olmalı
sudo docker-compose up -d  # Tekrar başlat
```

**Log kontrolü:**
```bash
sudo docker-compose logs web --tail=50
sudo docker-compose logs db --tail=50
```

### 404 Hatası (Ana Sayfa Yüklenmiyor)

**Sebep:** APP_DOMAIN'de port var!

**Çözüm:**
```bash
nano .env
# APP_DOMAIN="54.221.128.45:8080"  ← YANLIŞ!
# APP_DOMAIN="54.221.128.45"        ← DOĞRU!
```

Düzelt ve script'i tekrar çalıştır:
```bash
./setup-pixelfed.sh
```

### Port 8080 Açık mı?

AWS Console → Security Groups → Inbound Rules kontrol et.

---

## Başarı Kriterleri

### ⭐ 60 Puan (Temel Kurulum)
- [ ] EC2 instance oluşturuldu
- [ ] Docker kuruldu
- [ ] Repository klonlandı
- [ ] .env dosyası düzenlendi
- [ ] Konteynerler çalışıyor

### ⭐ 80 Puan (Script Çalıştı)
- [ ] setup-pixelfed.sh başarıyla çalıştı
- [ ] Migration tamamlandı
- [ ] Admin kullanıcı oluşturuldu

### ⭐ 100 Puan (Web Erişim)
- [ ] Web arayüzüne erişilebiliyor
- [ ] Login başarılı
- [ ] Timeline yükleniyor
- [ ] 404 hatası YOK!

---

## Manuel Kurulum (Script Kullanmadan)

Script sorun verirse manuel adımlar:

```bash
# Migration
sudo docker-compose exec web php artisan migrate --force

# Key generate
sudo docker-compose exec web php artisan key:generate

# Storage link
sudo docker-compose exec web php artisan storage:link

# Cache
sudo docker-compose exec web php artisan config:cache
sudo docker-compose exec web php artisan route:cache
sudo docker-compose exec web php artisan view:cache

# Instance actor
sudo docker-compose exec web php artisan instance:actor

# Package discovery & Horizon
sudo docker-compose exec web php artisan package:discover
sudo docker-compose exec web php artisan horizon:install

# Final cache rebuild
sudo docker-compose exec web php artisan route:cache
sudo docker-compose restart web
sleep 3
```

---

## Notlar

**Öğrencinin yapması gerekenler (özet):**
1. ✅ EC2 oluştur
2. ✅ SSH bağlan
3. ✅ Docker kur
4. ✅ Repo klonla
5. ✅ .env düzenle (5 alan) - **APP_DOMAIN'de PORT YOK!**
6. ✅ Container başlat
7. ✅ **Script çalıştır** (`./setup-pixelfed.sh`)
8. ✅ Admin user oluştur
9. ✅ Tarayıcıdan test et

**Script sayesinde 7 adım otomatik!**

**Eğitmen kontrolü:**
```bash
# Hızlı kontrol
curl -I http://<STUDENT_IP>:8080/ | head -1
# HTTP/1.1 200 OK olmalı, 404 OLMAMALI!
```
