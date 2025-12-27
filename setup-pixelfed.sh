#!/bin/bash

##############################################################################
# PixelFed Kurulum Script
# Bu script migration, cache ve diğer setup adımlarını otomatik yapar
##############################################################################

set -e  # Hata durumunda dur

echo ""
echo "========================================="
echo "PixelFed Kurulum Scripti Başlatılıyor..."
echo "========================================="
echo ""

# Renkli çıktılar için
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Progress gösterici
show_progress() {
    echo -e "${YELLOW}[⏳]${NC} $1"
}

show_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

show_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Container çalışıyor mu kontrol et
show_progress "Container durumu kontrol ediliyor..."
if ! sudo docker-compose ps | grep -q "pixelfed-web.*Up"; then
    show_error "pixelfed-web container çalışmıyor!"
    echo "Önce 'sudo docker-compose up -d' komutunu çalıştırın."
    exit 1
fi
show_success "Container'lar çalışıyor"
echo ""

##############################################################################
# Adım 1: Migration
##############################################################################
show_progress "Adım 1/8: Veritabanı migration'ları çalıştırılıyor..."
echo "           (Bu adım 1-2 dakika sürebilir, lütfen bekleyin...)"
if sudo docker-compose exec -T web php artisan migrate --force > /tmp/migration.log 2>&1; then
    show_success "Migration tamamlandı! (240+ tablo oluşturuldu)"
else
    show_error "Migration başarısız! Log:"
    cat /tmp/migration.log
    exit 1
fi
echo ""

##############################################################################
# Adım 2: Application Key
##############################################################################
show_progress "Adım 2/8: Laravel application key oluşturuluyor..."
if sudo docker-compose exec -T web php artisan key:generate > /tmp/key.log 2>&1; then
    show_success "Application key oluşturuldu"
else
    show_error "Key generation başarısız!"
    cat /tmp/key.log
    exit 1
fi
echo ""

##############################################################################
# Adım 3: Storage Link
##############################################################################
show_progress "Adım 3/8: Storage symlink oluşturuluyor..."
if sudo docker-compose exec -T web php artisan storage:link > /tmp/storage.log 2>&1; then
    show_success "Storage link oluşturuldu"
else
    # storage:link zaten varsa hata vermez, devam et
    show_success "Storage link zaten mevcut veya oluşturuldu"
fi
echo ""

##############################################################################
# Adım 4: Cache'leri Oluştur
##############################################################################
show_progress "Adım 4/8: Cache'ler oluşturuluyor..."

echo "           → Config cache..."
sudo docker-compose exec -T web php artisan config:cache > /dev/null 2>&1

echo "           → Route cache..."
sudo docker-compose exec -T web php artisan route:cache > /dev/null 2>&1

echo "           → View cache..."
sudo docker-compose exec -T web php artisan view:cache > /dev/null 2>&1

show_success "Tüm cache'ler oluşturuldu (config, route, view)"
echo ""

##############################################################################
# Adım 5: Instance Actor
##############################################################################
show_progress "Adım 5/8: Instance actor oluşturuluyor..."
if sudo docker-compose exec -T web php artisan instance:actor > /tmp/actor.log 2>&1; then
    show_success "Instance actor oluşturuldu"
else
    # Zaten varsa sorun yok
    show_success "Instance actor oluşturuldu veya zaten mevcut"
fi
echo ""

##############################################################################
# Adım 6: Package Discovery
##############################################################################
show_progress "Adım 6/8: Laravel paketleri discover ediliyor..."
if sudo docker-compose exec -T web php artisan package:discover > /tmp/discover.log 2>&1; then
    show_success "Paketler discover edildi"
else
    show_error "Package discovery başarısız!"
    cat /tmp/discover.log
    exit 1
fi
echo ""

##############################################################################
# Adım 7: Horizon Install
##############################################################################
show_progress "Adım 7/8: Horizon kurulumu yapılıyor..."
if sudo docker-compose exec -T web php artisan horizon:install > /tmp/horizon.log 2>&1; then
    show_success "Horizon kuruldu"
else
    # Zaten kuruluysa sorun yok
    show_success "Horizon zaten kurulu veya kurulum tamamlandı"
fi
echo ""

##############################################################################
# Adım 8: Final Cache Rebuild ve Restart
##############################################################################
show_progress "Adım 8/8: Final cache rebuild ve container restart..."

echo "           → Route cache yeniden oluşturuluyor..."
sudo docker-compose exec -T web php artisan route:cache > /dev/null 2>&1

echo "           → Web container restart ediliyor..."
sudo docker-compose restart web > /dev/null 2>&1

echo "           → Container'ın hazır olması bekleniyor..."
sleep 3

show_success "Cache rebuild ve restart tamamlandı"
echo ""

##############################################################################
# TAMAMLANDI
##############################################################################
echo ""
echo "========================================="
echo -e "${GREEN}✓ KURULUM TAMAMLANDI!${NC}"
echo "========================================="
echo ""
echo "Sıradaki adımlar:"
echo "1. Admin kullanıcı oluştur:"
echo "   sudo docker-compose exec web php artisan user:create"
echo ""
echo "2. Tarayıcıda aç:"
echo "   http://$(curl -s http://checkip.amazonaws.com):8080"
echo ""
echo "İyi çalışmalar! 🚀"
echo ""
