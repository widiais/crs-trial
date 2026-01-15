# Troubleshooting Guide

## Masalah: Tidak Bisa Login

### Gejala
- Klik tombol login tidak berfungsi
- Error "Unauthorized" saat akses API
- Session tidak tersimpan

### Penyebab & Solusi

#### 1. Environment Variables Tidak Lengkap

**Cek:**
```bash
cd docker
cat .env
```

**Pastikan ada:**
- `SESSION_SECRET` - Harus diisi dengan random string
- `NEXT_PUBLIC_APP_URL` - Harus sesuai dengan URL aplikasi
- `COOKIE_SECURE` - Harus sesuai dengan protokol (HTTP=false, HTTPS=true)

**Solusi:**
```bash
# Generate secure values
./setup-env.sh your-domain.com

# Atau manual
SESSION_SECRET=$(openssl rand -base64 32)
echo "SESSION_SECRET=$SESSION_SECRET" >> .env
```

#### 2. Cookie Secure Setting Salah

**Masalah:** Jika `COOKIE_SECURE=true` tapi menggunakan HTTP, cookie tidak akan dikirim.

**Solusi:**
```bash
# Untuk HTTP (tanpa SSL)
COOKIE_SECURE=false

# Untuk HTTPS (dengan SSL)
COOKIE_SECURE=true
```

#### 3. NEXT_PUBLIC_APP_URL Tidak Sesuai

**Masalah:** URL di env tidak sesuai dengan URL yang digunakan untuk akses.

**Solusi:**
```bash
# Cek URL saat ini
echo $NEXT_PUBLIC_APP_URL

# Update sesuai kebutuhan
# Untuk IP: http://YOUR_IP:3000
# Untuk domain: http://your-domain.com
# Untuk HTTPS: https://your-domain.com
```

#### 4. Container Tidak Restart Setelah Update Env

**Solusi:**
```bash
# Restart container setelah update .env
./deploy.sh restart

# Atau rebuild
./deploy.sh stop
./deploy.sh start
```

## Masalah: Database Error

### Gejala
- Error "table does not exist"
- Tidak bisa create/read data
- Error "P1012" - datasource property url is no longer supported

### Solusi

```bash
# Setup database schema (recommended)
./deploy.sh setup-db

# Atau manual - PENTING: gunakan prisma@6.1.0
docker exec crs-trial npx prisma@6.1.0 db push
```

**⚠️ JANGAN gunakan:**
```bash
docker exec crs-trial npx prisma db push  # ❌ Akan download Prisma v7
```

### Problem: Prisma Version Mismatch (Error P1012)

**Error:**
```
Error code: P1012
error: The datasource property `url` is no longer supported in schema files.
Prisma CLI Version : 7.2.0
```

**Penyebab:**
- Container otomatis install Prisma CLI v7.x saat run `npx prisma`
- Project menggunakan Prisma Client v6.1.0
- Prisma v7 mengubah cara konfigurasi datasource

**Solusi:**
1. **Selalu gunakan versi spesifik:**
   ```bash
   docker exec crs-trial npx prisma@6.1.0 db push
   ```

2. **Pastikan DATABASE_URL ada di .env:**
   ```bash
   # Cek .env file
   cat docker/.env | grep DATABASE_URL
   
   # Jika tidak ada, tambahkan:
   # Format: postgresql://user:pass@postgres:5432/db?schema=public
   # HOST harus "postgres" (nama service), bukan "localhost"
   ```

3. **Restart container setelah update .env:**
   ```bash
   ./deploy.sh restart
   ```

## Masalah: Container Tidak Start

### Cek Logs
```bash
./deploy.sh logs

# Atau specific service
docker logs crs-trial
docker logs crs-trial-db-prod
```

### Cek Status
```bash
./deploy.sh status

# Atau
docker ps -a | grep crs-trial
```

## Masalah: Port Already in Use

### Solusi
```bash
# Cek port yang digunakan
sudo netstat -tulpn | grep :3000

# Atau ubah port di .env
APP_PORT=3001
```

## Checklist Deployment

Sebelum deploy, pastikan:

- [ ] File `.env` sudah dibuat
- [ ] `SESSION_SECRET` sudah di-generate (bukan default)
- [ ] `POSTGRES_PASSWORD` sudah di-set (bukan default)
- [ ] `NEXT_PUBLIC_APP_URL` sesuai dengan URL akses
- [ ] `COOKIE_SECURE` sesuai dengan protokol (HTTP/HTTPS)
- [ ] Database schema sudah di-push (`./deploy.sh setup-db`)
- [ ] Container status healthy (`./deploy.sh status`)

## Quick Fix Commands

```bash
# Regenerate .env file
./setup-env.sh your-domain.com

# Restart semua
./deploy.sh restart

# Rebuild dan restart
./deploy.sh stop
./deploy.sh start

# Cek environment variables di container
docker exec crs-trial env | grep -E "SESSION|COOKIE|URL"

# Test API
curl http://localhost:3000/api/health
```
