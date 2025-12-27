# PixelFed Docker Kurulum Rehberi

Bu rehber, PixelFed'i AWS EC2 üzerinde Docker kullanarak nasıl kuracağınızı adım adım anlatmaktadır.

## Gereksinimler

- AWS EC2 instance (t2.medium veya daha güçlü)
- Amazon Linux 2023
- Docker ve Docker Compose kurulu
- Port 8080 açık (Security Group'ta)
- En az 4GB RAM

## Adım 1: Repository'yi Clone Edin

```bash
git clone <REPO_URL>
cd pixelfed
```

## Adım 2: .env Dosyasını Oluşturun

```bash
cp .env.docker .env
```

## Adım 3: .env Dosyasını Düzenleyin

`.env` dosyasını bir metin editörü ile açın ve aşağıdaki alanları doldurun:

```bash
nano .env
```

### Zorunlu Alanlar:

**1. Uygulama Bilgileri:**
```bash
APP_NAME="PixelFed"
APP_DOMAIN="<EC2_PUBLIC_IP>:8080"    # Örnek: 54.221.128.45:8080
APP_URL="http://<EC2_PUBLIC_IP>:8080"  # Örnek: http://54.221.128.45:8080
```

**2. İletişim Bilgisi:**
```bash
INSTANCE_CONTACT_EMAIL="admin@pixelfed.local"
```

**3. Veritabanı Şifresi:**
```bash
DB_PASSWORD="<GÜÇLÜ_ŞİFRE>"  # Örnek: PixelFed2025_Secure!
```

**NOT:**
- `<EC2_PUBLIC_IP>` yerine kendi EC2 instance'ınızın public IP adresini yazın
- `<GÜÇLÜ_ŞİFRE>` yerine güvenli bir şifre belirleyin

Dosyayı kaydedin ve kapatın (nano'da: `CTRL+X`, sonra `Y`, sonra `ENTER`)

## Adım 4: Container'ları Başlatın

```bash
sudo docker-compose up -d
```

Bu komut şu container'ları başlatacak:
- `pixelfed-web` - Web sunucusu
- `pixelfed-worker` - Background işler
- `pixelfed-cron` - Zamanlanmış görevler
- `pixelfed-db` - MariaDB veritabanı
- `pixelfed-redis` - Redis cache

Container durumunu kontrol edin:
```bash
sudo docker-compose ps
```

Tüm container'lar "Up" durumunda olmalı.

## Adım 5: Veritabanı Migration'larını Çalıştırın

**ÖNEMLİ:** Bu adım otomatik değil, manuel yapılmalıdır.

Web container'a girin:
```bash
sudo docker-compose exec web bash
```

Container içinde migration'ları çalıştırın:
```bash
php artisan migrate --force
```

Migration'lar tamamlandığında şöyle bir çıktı göreceksiniz:
```
INFO  Running migrations.

  2018_04_03_125338_create_stories_table ............... DONE
  2018_04_19_054343_add_remote_url_to_profiles ......... DONE
  ...
```

Container'dan çıkın:
```bash
exit
```

## Adım 6: Uygulama Key'ini Oluşturun

```bash
sudo docker-compose exec web php artisan key:generate
```

## Adım 7: Storage Link'ini Oluşturun

```bash
sudo docker-compose exec web php artisan storage:link
```

## Adım 8: Cache'i Temizleyin

```bash
sudo docker-compose exec web php artisan config:cache
sudo docker-compose exec web php artisan route:cache
sudo docker-compose exec web php artisan view:cache
```

## Adım 9: Admin Kullanıcı Oluşturun

Web container'a girin:
```bash
sudo docker-compose exec web bash
```

Admin kullanıcı oluşturun:
```bash
php artisan user:create
```

Sizden istenecek bilgiler:
- **Username:** admin (veya istediğiniz kullanıcı adı)
- **Email:** admin@pixelfed.local
- **Name:** Administrator
- **Password:** Güçlü bir şifre belirleyin
- **Confirm Password:** Şifreyi tekrar girin
- **Make this user an admin?:** yes

Container'dan çıkın:
```bash
exit
```

## Adım 10: Web Arayüzüne Erişin

Tarayıcınızda şu adresi açın:
```
http://<EC2_PUBLIC_IP>:8080
```

**NOT:** `https://` değil, `http://` kullanın!

Giriş yapın:
- Kullanıcı adı veya email: az önce oluşturduğunuz bilgiler
- Şifre: az önce belirlediğiniz şifre

## Sorun Giderme

### Container'lar Başlamıyor

Logları kontrol edin:
```bash
sudo docker-compose logs
```

Belirli bir container'ın loglarına bakın:
```bash
sudo docker-compose logs web
sudo docker-compose logs db
sudo docker-compose logs worker
```

### Port 8080'e Erişilemiyor

AWS Security Group ayarlarını kontrol edin:
1. EC2 Dashboard → Security Groups
2. İlgili Security Group'u seçin
3. Inbound Rules → Edit
4. Custom TCP, Port 8080, Source: 0.0.0.0/0 kuralı olmalı

### Veritabanı Bağlantı Hatası

DB container'ın çalıştığını kontrol edin:
```bash
sudo docker-compose ps db
```

DB loglarına bakın:
```bash
sudo docker-compose logs db
```

### Migration Hatası

Migration'ları tekrar çalıştırmayı deneyin:
```bash
sudo docker-compose exec web php artisan migrate:fresh --force
```

**DİKKAT:** `migrate:fresh` tüm veritabanını siler ve sıfırdan oluşturur!

## Container'ları Durdurma ve Yeniden Başlatma

### Durdurma:
```bash
sudo docker-compose down
```

### Yeniden Başlatma:
```bash
sudo docker-compose up -d
```

### Tümünü Silme (Veritabanı dahil):
```bash
sudo docker-compose down -v
```

**DİKKAT:** `-v` parametresi tüm volume'leri (veritabanı dahil) siler!

## Öğrenme Hedefleri

Bu kurulumda şunları öğrendiniz:
1. **Docker Compose** kullanarak multi-container uygulama başlatma
2. **Environment variables** (.env) yönetimi
3. **Docker container'a girme** ve komut çalıştırma
4. **Laravel Migration** nedir ve nasıl çalıştırılır
5. **Cache yönetimi** (config, route, view cache)
6. **Artisan komutları** kullanımı

## Ek Kaynaklar

- [PixelFed Resmi Dokümantasyon](https://docs.pixelfed.org/)
- [Docker Compose Dokümantasyon](https://docs.docker.com/compose/)
- [Laravel Artisan Komutları](https://laravel.com/docs/artisan)
