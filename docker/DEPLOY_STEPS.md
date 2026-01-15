# Step-by-Step Deployment Guide ke VPS Hostinger

Panduan lengkap untuk deploy aplikasi CRS Trial ke VPS Hostinger menggunakan Docker.

---

## 📋 Prerequisites

Sebelum mulai, pastikan Anda sudah memiliki:
- ✅ VPS Hostinger yang sudah aktif
- ✅ SSH access ke VPS
- ✅ Domain (optional, bisa pakai IP)
- ✅ Git repository sudah di-push ke GitHub

---

## 🚀 Step 1: Setup VPS Hostinger

### 1.1 Login ke VPS

```bash
# Dari local machine, SSH ke VPS
ssh root@YOUR_VPS_IP
# atau
ssh username@YOUR_VPS_IP
```

**Catatan:** Ganti `YOUR_VPS_IP` dengan IP VPS Anda dari Hostinger dashboard.

### 1.2 Update System

```bash
# Update package list
apt update && apt upgrade -y
```

### 1.3 Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

**Expected output:**
```
Docker version 24.x.x
Docker Compose version v2.x.x
```

---

## 📥 Step 2: Clone Repository

### 2.1 Pilih Lokasi untuk Aplikasi

```bash
# Buat folder untuk aplikasi
mkdir -p /var/www
cd /var/www
```

### 2.2 Clone dari GitHub

```bash
# Clone repository
git clone https://github.com/widiais/crs-trial.git
cd crs-trial
```

**Atau jika repository private:**
```bash
# Clone dengan SSH (jika sudah setup SSH key)
git clone git@github.com:widiais/crs-trial.git
cd crs-trial
```

---

## ⚙️ Step 3: Setup Environment Variables

### 3.1 Masuk ke Folder Docker

```bash
cd docker
```

### 3.2 Generate Environment File (Recommended)

```bash
# Buat file .env otomatis
./setup-env.sh YOUR_DOMAIN_OR_IP
```

**Contoh:**
```bash
# Jika pakai domain
./setup-env.sh yourdomain.com

# Jika pakai IP
./setup-env.sh 123.456.789.0
```

Script akan:
- Generate secure password untuk PostgreSQL
- Generate secure session secret
- Setup semua environment variables **termasuk DATABASE_URL**
- Menampilkan semua generated values

**⚠️ PENTING:** 
- Simpan semua generated values yang ditampilkan!
- Script sudah otomatis generate `DATABASE_URL` dengan format yang benar

### 3.3 Atau Setup Manual

Jika ingin setup manual:

```bash
nano .env
```

Isi dengan:

```env
# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=GANTI_DENGAN_PASSWORD_KUAT
POSTGRES_DB=crs_trial
POSTGRES_PORT=5432

# Database URL (WAJIB untuk Prisma)
# Format: postgresql://USER:PASSWORD@HOST:PORT/DATABASE?schema=SCHEMA
# HOST: gunakan nama service dari docker-compose (postgres) bukan localhost
DATABASE_URL="postgresql://postgres:GANTI_DENGAN_PASSWORD_KUAT@postgres:5432/crs_trial?schema=public"

# Application Configuration
APP_PORT=3000
SESSION_SECRET=GANTI_DENGAN_RANDOM_STRING_PANJANG
NEXT_PUBLIC_APP_URL=http://YOUR_DOMAIN_OR_IP:3000
COOKIE_SECURE=false
NODE_ENV=production
```

**⚠️ PENTING tentang DATABASE_URL:**
- **WAJIB ada** di `.env` file
- **HOST:** Gunakan `postgres` (nama service di docker-compose), **BUKAN** `localhost`
- Format: `postgresql://USER:PASSWORD@HOST:PORT/DATABASE?schema=public`
- DATABASE_URL juga akan di-generate otomatis oleh `setup-env.sh`

**Generate secure values:**
```bash
# Generate PostgreSQL password
openssl rand -base64 16 | tr -d "=+/" | cut -c1-20

# Generate Session Secret
openssl rand -base64 32
```

---

## 🐳 Step 4: Deploy dengan Docker

### 4.1 Start Services

```bash
# Start semua services (PostgreSQL + Next.js App)
./deploy.sh start
```

**Atau manual:**
```bash
docker-compose -f docker-compose.prod.yaml --env-file .env up -d --build
```

**Proses ini akan:**
- Build Next.js application
- Start PostgreSQL container
- Start Next.js app container
- Setup Docker network

**Waktu:** Sekitar 5-10 menit untuk pertama kali (download images & build)

### 4.2 Check Status

```bash
# Check container status
./deploy.sh status

# Atau
docker ps
```

**Expected output:**
```
NAMES               STATUS                    PORTS
crs-trial           Up X minutes (healthy)    0.0.0.0:3000->3000/tcp
crs-trial-db-prod   Up X minutes (healthy)    0.0.0.0:5432->5432/tcp
```

### 4.3 Check Logs (Optional)

```bash
# View logs
./deploy.sh logs

# Atau specific service
docker logs crs-trial
docker logs crs-trial-db-prod
```

---

## 🗄️ Step 5: Setup Database Schema

### 5.1 Push Database Schema

```bash
# Setup database schema
./deploy.sh setup-db
```

**Atau manual:**
```bash
# PENTING: Gunakan prisma@6.1.0 (bukan prisma saja)
# Karena container mungkin install Prisma v7 yang berbeda dengan project
docker exec crs-trial npx prisma@6.1.0 db push
```

**⚠️ PENTING - Prisma Version Mismatch:**
- Project menggunakan Prisma Client v6.1.0
- Container mungkin install Prisma CLI v7.x secara otomatis
- Prisma v7 tidak support `url = env("DATABASE_URL")` di schema
- **Selalu gunakan `prisma@6.1.0`** untuk semua Prisma commands

**Jika error "P1012" atau "datasource property url is no longer supported":**
```bash
# Gunakan versi spesifik
docker exec crs-trial npx prisma@6.1.0 db push

# Bukan
docker exec crs-trial npx prisma db push  # ❌ Akan download v7
```

**Expected output:**
```
🚀  Your database is now in sync with your Prisma schema.
```

### 5.2 Verify Database

```bash
# Check tables
docker exec crs-trial-db-prod psql -U postgres -d crs_trial -c "\dt"
```

**Expected output:**
```
           List of relations
 Schema |    Name    | Type  |  Owner   
--------+------------+-------+----------
 public | categories | table | postgres
```

---

## ✅ Step 6: Verify Deployment

### 6.1 Test Health Endpoint

```bash
# Test dari VPS
curl http://localhost:3000/api/health
```

**Expected output:**
```json
{"status":"ok"}
```

### 6.2 Test dari Browser

Buka browser dan akses:
- **Dengan IP:** `http://YOUR_VPS_IP:3000`
- **Dengan Domain:** `http://yourdomain.com:3000`

**Expected:**
- Halaman login muncul
- Bisa klik tombol "Login"
- Redirect ke dashboard
- Bisa akses Setup Categories

### 6.3 Test Login & CRUD

1. **Login:**
   - Klik tombol "Login"
   - Harus redirect ke dashboard

2. **Create Category:**
   - Klik "Setup Categories" di sidebar
   - Klik "Add Category"
   - Isi name, centang active
   - Klik "Create"
   - Category harus muncul di tabel

3. **Edit Category:**
   - Klik icon edit pada category
   - Ubah name atau active status
   - Klik "Update"
   - Perubahan harus tersimpan

4. **Delete Category:**
   - Klik icon delete
   - Confirm deletion
   - Category harus terhapus

---

## 🔧 Step 7: Setup Firewall (Optional)

### 7.1 Allow Port 3000

```bash
# Install UFW jika belum ada
apt install ufw -y

# Allow SSH (penting!)
ufw allow 22/tcp

# Allow port aplikasi
ufw allow 3000/tcp

# Enable firewall
ufw enable

# Check status
ufw status
```

---

## 🌐 Step 8: Setup Domain & Nginx (Optional)

Jika Anda punya domain dan ingin setup reverse proxy:

### 8.1 Install Nginx

```bash
apt install nginx -y
```

### 8.2 Create Nginx Config

```bash
nano /etc/nginx/sites-available/crs-trial
```

Isi dengan:

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

**Ganti `yourdomain.com` dengan domain Anda!**

### 8.3 Enable Site

```bash
# Create symlink
ln -s /etc/nginx/sites-available/crs-trial /etc/nginx/sites-enabled/

# Test config
nginx -t

# Reload Nginx
systemctl reload nginx
```

### 8.4 Update Environment Variable

```bash
cd /var/www/crs-trial/docker
nano .env
```

Update:
```env
NEXT_PUBLIC_APP_URL=http://yourdomain.com
```

Restart app:
```bash
./deploy.sh restart
```

---

## 📝 Step 9: Maintenance Commands

### 9.1 Useful Commands

```bash
# Start services
./deploy.sh start

# Stop services
./deploy.sh stop

# Restart services
./deploy.sh restart

# View logs
./deploy.sh logs

# Update application (setelah git pull)
./deploy.sh update

# Check status
./deploy.sh status

# Setup database
./deploy.sh setup-db
```

### 9.2 Update Application

```bash
# Pull latest code
cd /var/www/crs-trial
git pull

# Rebuild dan restart
cd docker
./deploy.sh update
```

### 9.3 Backup Database

```bash
# Backup database
docker exec crs-trial-db-prod pg_dump -U postgres crs_trial > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database (jika perlu)
cat backup.sql | docker exec -i crs-trial-db-prod psql -U postgres crs_trial
```

---

## 🐛 Troubleshooting

### Problem: Tidak bisa login

**Solusi:**
1. Cek `.env` file sudah lengkap
2. Pastikan `COOKIE_SECURE=false` jika pakai HTTP
3. Restart: `./deploy.sh restart`
4. Lihat logs: `./deploy.sh logs`

### Problem: Database error

**Solusi:**
```bash
./deploy.sh setup-db
```

### Problem: Prisma Error P1012 - "datasource property url is no longer supported"

**Gejala:**
```
Error code: P1012
error: The datasource property `url` is no longer supported in schema files.
```

**Penyebab:**
- Container menggunakan Prisma CLI v7.x (otomatis terinstall)
- Project menggunakan Prisma Client v6.1.0
- Prisma v7 tidak support format lama

**Solusi:**
```bash
# Gunakan versi spesifik Prisma v6.1.0
docker exec crs-trial npx prisma@6.1.0 db push

# Atau
./deploy.sh setup-db  # Script sudah menggunakan versi yang benar
```

**Pastikan juga:**
- `DATABASE_URL` ada di `.env` file
- Format DATABASE_URL benar: `postgresql://user:pass@postgres:5432/db?schema=public`
- HOST menggunakan `postgres` (nama service), bukan `localhost`

### Problem: Port sudah digunakan

**Solusi:**
```bash
# Cek port
netstat -tulpn | grep :3000

# Atau ubah port di .env
APP_PORT=3001
```

### Problem: Container tidak start

**Solusi:**
```bash
# Check logs
docker logs crs-trial
docker logs crs-trial-db-prod

# Check status
docker ps -a
```

Lihat `TROUBLESHOOTING.md` untuk panduan lengkap.

---

## ✅ Checklist Deployment

Sebelum selesai, pastikan:

- [ ] Docker dan Docker Compose terinstall
- [ ] Repository sudah di-clone
- [ ] File `.env` sudah dibuat dan lengkap
- [ ] `SESSION_SECRET` sudah di-generate (bukan default)
- [ ] `POSTGRES_PASSWORD` sudah di-set (bukan default)
- [ ] `NEXT_PUBLIC_APP_URL` sesuai dengan URL akses
- [ ] `COOKIE_SECURE` sesuai dengan protokol (HTTP/HTTPS)
- [ ] Containers running dan healthy
- [ ] Database schema sudah di-push
- [ ] Health endpoint merespons OK
- [ ] Bisa login dari browser
- [ ] CRUD categories berfungsi

---

## 🎉 Selesai!

Aplikasi Anda sudah berjalan di VPS Hostinger!

**Akses aplikasi:**
- IP: `http://YOUR_VPS_IP:3000`
- Domain: `http://yourdomain.com:3000` (jika sudah setup)

**Next Steps:**
- Setup SSL/HTTPS dengan Let's Encrypt (optional)
- Setup automatic backups
- Monitor logs secara berkala
- **Setup Auto-Deploy dengan GitHub Actions** (lihat Step 10)

---

## 🤖 Step 10: Setup Auto-Deploy dengan GitHub Actions (Optional)

Setup CI/CD untuk auto-deploy setiap ada push ke branch `main`.

### 10.1 Setup SSH Key di VPS

```bash
# Di VPS
cd /var/www/crs-trial/docker
./setup-github-actions.sh
```

Script akan:
- Generate SSH key khusus untuk GitHub Actions
- Setup authorized_keys
- Menampilkan private key untuk di-copy ke GitHub Secrets

**⚠️ PENTING:** Simpan private key yang ditampilkan!

### 10.2 Setup GitHub Secrets

Di GitHub repository:
1. Buka **Settings → Secrets and variables → Actions**
2. Klik **New repository secret**
3. Tambahkan secrets berikut:

**VPS_SSH_PRIVATE_KEY:**
- Value: Private key yang di-copy dari VPS (seluruh isi, termasuk BEGIN/END lines)

**VPS_HOST:**
- Value: IP VPS atau domain (contoh: `123.456.789.0`)

**VPS_USER:**
- Value: Username SSH (biasanya `root`)

**VPS_URL** (optional):
- Value: URL aplikasi (contoh: `http://yourdomain.com:3000`)

### 10.3 Test Auto-Deploy

Setelah setup:
1. **Push ke branch main:**
   ```bash
   git push origin main
   ```

2. **Atau manual trigger:**
   - Buka **Actions** tab di GitHub
   - Pilih **Deploy to VPS** workflow
   - Klik **Run workflow**

3. **Monitor deployment:**
   - Buka **Actions** tab untuk melihat progress
   - Deployment akan otomatis:
     - Pull latest code
     - Rebuild containers
     - Restart services
     - Setup database schema
     - Health check

### 10.4 Workflow Details

Workflow akan otomatis:
- ✅ Trigger saat push ke `main` branch
- ✅ Checkout code terbaru
- ✅ SSH ke VPS
- ✅ Pull latest code
- ✅ Rebuild Docker containers
- ✅ Restart services
- ✅ Setup database schema
- ✅ Health check

**File workflow:** `.github/workflows/deploy.yml`

**Dokumentasi lengkap:** Lihat `.github/workflows/README.md`

---

## 📞 Support

Jika ada masalah:
1. Cek `TROUBLESHOOTING.md`
2. Cek logs: `./deploy.sh logs`
3. Cek container status: `./deploy.sh status`
