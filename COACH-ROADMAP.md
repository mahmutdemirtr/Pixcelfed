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

## Adım 8: Veritabanı Migration

```bash
sudo docker-compose exec web php artisan migrate --force
```

**240+ tablo oluşturulacak. 1-2 dakika sürer.**

**Başarılı çıktı:**
```
INFO  Running migrations.
  2018_04_03_125338_create_stories_table .... DONE
  ...
```

---

## Adım 9: Uygulama Key'i Oluştur

```bash
sudo docker-compose exec web php artisan key:generate
```

**Çıktı:**
```
Application key set successfully.
```

---

## Adım 10: Storage Link Oluştur

```bash
sudo docker-compose exec web php artisan storage:link
```

---

## Adım 11: Cache Oluştur

```bash
sudo docker-compose exec web php artisan config:cache
sudo docker-compose exec web php artisan route:cache
sudo docker-compose exec web php artisan view:cache
```

---

## Adım 12: Instance Actor Oluştur

```bash
sudo docker-compose exec web php artisan instance:actor
```

---

## Adım 13: Package Discovery & Horizon

```bash
sudo docker-compose exec web php artisan package:discover
sudo docker-compose exec web php artisan horizon:install
```

---

## Adım 14: Final Cache Rebuild

```bash
sudo docker-compose exec web php artisan route:cache
sudo docker-compose restart web
```

**3 saniye bekle:**
```bash
sleep 3
```

---

## Adım 15: Admin Kullanıcı Oluştur

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

## Adım 16: Web Test

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

### 404 Hatası (Ana Sayfa Yüklenmiyor)

**Sebep:** APP_DOMAIN'de port var!

**Çözüm:**
```bash
nano .env
# APP_DOMAIN="54.221.128.45:8080"  ← YANLIŞ!
# APP_DOMAIN="54.221.128.45"        ← DOĞRU!
```

Düzelt ve yeniden cache:
```bash
sudo docker-compose exec web php artisan config:clear
sudo docker-compose exec web php artisan config:cache
sudo docker-compose restart web
```

### Container Başlamıyor

```bash
sudo docker-compose logs web --tail=50
sudo docker-compose logs db --tail=50
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

### ⭐ 80 Puan (Migration & Admin)
- [ ] Migration tamamlandı
- [ ] Admin kullanıcı oluşturuldu
- [ ] Veritabanında kullanıcı görünüyor

### ⭐ 100 Puan (Web Erişim)
- [ ] Web arayüzüne erişilebiliyor
- [ ] Login başarılı
- [ ] Timeline yükleniyor
- [ ] 404 hatası YOK!

---

## Notlar

**Öğrencinin yaşayabileceği hatalar:**

1. **APP_DOMAIN'e port ekleme** → En sık yapılan hata!
2. Migration'ı unutma
3. Cache komutlarını atlama
4. instance:actor'u çalıştırmama
5. Security Group'ta 8080 portunu açmama

**Eğitmen kontrolü:**
```bash
# Hızlı kontrol scripti
curl -I http://<STUDENT_IP>:8080/ | head -1
# HTTP/1.1 200 OK olmalı, 404 OLMAMALI!
```
