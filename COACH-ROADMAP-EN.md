# PixelFed Installation - Instructor Solution Guide

## Step 1: Create AWS EC2

### AWS Console

```
URL: https://console.aws.amazon.com/
Services → EC2 → Launch Instance
```

### Instance Settings

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


**Launch and note Public IP**

---

## Step 2: SSH Connection

### Connect via SSH

```bash
chmod 400 pixelfed-key.pem
ssh -i pixelfed-key.pem ec2-user@<PUBLIC_IP>
```

---

## Step 3: System Update

### Update Package List

```bash
sudo yum update -y
```

### Install Required Tools

```bash
sudo yum install -y curl git
```

---

## Step 4: Docker Installation

### Install Docker

```bash
sudo yum install -y docker
```

### Start Docker Service

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Add User to Docker Group

```bash
sudo usermod -aG docker ec2-user
```

### Install Docker Compose

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

## Step 5: Clone PixelFed Repository

### Clone Repository

```bash
cd ~
git clone https://github.com/mahmutdemirtr/Pixcelfed.git pixelfed
cd pixelfed
```

### Check Files

```bash
ls -la
```

**Should see:**
- compose.yaml
- .env.docker
- setup-pixelfed.sh
- KURULUM.md

---

## Step 6: Create and Edit .env File

```bash
cp .env.docker .env
curl -s http://checkip.amazonaws.com  # Get Public IP
nano .env
```

### Edit 5 Fields (Search with Ctrl+W):

**1. APP_NAME (Line 10):**
```bash
APP_NAME="PixelFed"
```

**2. APP_DOMAIN (Line 13) - ⚠️ CRITICAL: NO PORT!**
```bash
APP_DOMAIN="<EC2_PUBLIC_IP>"
```
Example: `APP_DOMAIN="54.221.128.45"` (NO PORT!)

**3. APP_URL (Line 16):**
```bash
APP_URL="http://<EC2_PUBLIC_IP>:8080"
```
Example: `APP_URL="http://54.221.128.45:8080"`

**4. INSTANCE_CONTACT_EMAIL (Line 24):**
```bash
INSTANCE_CONTACT_EMAIL="admin@pixelfed.local"
```

**5. DB_PASSWORD (Line 30):**
```bash
DB_PASSWORD="PixelFed2025_Secure!"
```

### Save and Exit

```
Ctrl+O  → Save
Enter   → Confirm
Ctrl+X  → Exit
```

### Verify

```bash
grep -E "^APP_NAME=|^APP_DOMAIN=|^APP_URL=|^INSTANCE_CONTACT_EMAIL=|^DB_PASSWORD=" .env
```

**Expected output:**
```
APP_NAME="PixelFed"
APP_DOMAIN="54.221.128.45"
APP_URL="http://54.221.128.45:8080"
INSTANCE_CONTACT_EMAIL="admin@pixelfed.local"
DB_PASSWORD="PixelFed2025_Secure!"
```

---

## Step 7: Start Containers

```bash
sudo docker-compose up -d
```

**First run takes 2-3 minutes.**

### Check Status

```bash
sudo docker-compose ps
```

**All services should be "Up":**
- pixelfed-web
- pixelfed-worker
- pixelfed-db
- pixelfed-redis

---

## Step 8: Automated Setup Script

### Method 1: With Script (RECOMMENDED)

```bash
./setup-pixelfed.sh
```

## Step 9: Create Admin User

```bash
sudo docker-compose exec web php artisan user:create
```

**Enter in sequence:**
```
Username: admin
Email: admin@pixelfed.local
Name: Admin User
Password: Admin2025!
Confirm Password: Admin2025!
Make this user an admin? (yes/no): yes
Confirm user creation? (yes/no): yes
```

**Success output:**
```
Created new user!
```

---

## Step 10: Web Test

### Open in Browser

```
http://<EC2_PUBLIC_IP>:8080
```

Example: `http://54.221.128.45:8080`

### Homepage Test

- Page should load (NO 404!)
- PixelFed logo should be visible
- "Login" button in top right

### Login Test

```
Username: admin
Password: Admin2025!
```

- Login should succeed
- Timeline should display
- Left menu should show "Discover", "Groups", etc.

---
