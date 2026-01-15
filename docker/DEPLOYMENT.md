# Deployment Guide - VPS dengan Docker

Panduan lengkap untuk deploy aplikasi CRS Trial ke VPS menggunakan Docker.

## Prerequisites

- VPS dengan Ubuntu/Debian
- Docker dan Docker Compose terinstall
- SSH access ke VPS
- Domain (optional, untuk production)

## Step 1: Install Docker di VPS

Jika Docker belum terinstall:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group (optional, untuk tidak perlu sudo)
sudo usermod -aG docker $USER
```

## Step 2: Upload Code ke VPS

### Opsi A: Menggunakan Git (Recommended)

```bash
# Di VPS
cd /var/www  # atau folder yang diinginkan
git clone <your-repo-url> crs-trial
cd crs-trial
```

### Opsi B: Menggunakan SCP

```bash
# Di local machine
scp -r crs-trial/ user@your-vps-ip:/var/www/
```

## Step 3: Setup Environment Variables

### Opsi A: Menggunakan Setup Script (Recommended)

```bash
cd /var/www/crs-trial/docker
./setup-env.sh your-domain.com
# atau
./setup-env.sh YOUR_VPS_IP
```

Script ini akan:
- Generate secure password untuk PostgreSQL
- Generate secure session secret
- Setup environment variables dengan benar
- Menampilkan semua generated values untuk disimpan

### Opsi B: Manual Setup

```bash
cd /var/www/crs-trial/docker
nano .env
```

Isi dengan konfigurasi berikut:

```env
# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=CHANGE_THIS_TO_SECURE_PASSWORD
POSTGRES_DB=crs_trial
POSTGRES_PORT=5432

# Application Configuration
APP_PORT=3000
SESSION_SECRET=CHANGE_THIS_TO_RANDOM_SECRET_KEY
NEXT_PUBLIC_APP_URL=http://your-domain.com
COOKIE_SECURE=false
```

**PENTING**: 
- **POSTGRES_PASSWORD**: Ganti dengan password yang kuat (minimal 12 karakter)
- **SESSION_SECRET**: Generate dengan `openssl rand -base64 32` atau gunakan random string yang panjang
- **NEXT_PUBLIC_APP_URL**: 
  - Tanpa domain: `http://YOUR_VPS_IP:3000`
  - Dengan domain: `http://your-domain.com`
  - Dengan HTTPS: `https://your-domain.com`
- **COOKIE_SECURE**: 
  - `false` untuk HTTP (testing tanpa SSL)
  - `true` untuk HTTPS (production dengan SSL)

### Quick Setup Script

```bash
cd /var/www/crs-trial/docker

# Generate secure password and secret
POSTGRES_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
SESSION_SECRET=$(openssl rand -base64 32)

# Create .env file
cat > .env << EOF
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=crs_trial
POSTGRES_PORT=5432
APP_PORT=3000
SESSION_SECRET=$SESSION_SECRET
NEXT_PUBLIC_APP_URL=http://$(hostname -I | awk '{print $1}'):3000
COOKIE_SECURE=false
EOF

# Show the generated values (save them!)
echo "Generated .env file. Save these values:"
cat .env
```

## Step 4: Build dan Start Services

```bash
cd /var/www/crs-trial/docker
docker-compose -f docker-compose.prod.yaml --env-file .env up -d --build
```

Tunggu hingga build selesai. Proses ini akan:
1. Build Next.js application
2. Start PostgreSQL container
3. Start Next.js app container
4. Setup database schema

## Step 5: Setup Database Schema

Setelah containers running, setup database:

```bash
# Menggunakan deploy script (recommended)
./deploy.sh setup-db
```

Atau manual:

```bash
# PENTING: Gunakan prisma@6.1.0 (bukan prisma saja)
# Karena container mungkin install Prisma v7 yang berbeda dengan project
docker exec crs-trial npx prisma@6.1.0 db push
```

**⚠️ PENTING - Prisma Version:**
- Project menggunakan Prisma Client v6.1.0
- Container mungkin install Prisma CLI v7.x secara otomatis
- Prisma v7 tidak support `url = env("DATABASE_URL")` di schema
- **Selalu gunakan `prisma@6.1.0`** untuk semua Prisma commands

**Jika error "P1012" atau "datasource property url is no longer supported":**
- Pastikan menggunakan `prisma@6.1.0` bukan `prisma` saja
- Pastikan `DATABASE_URL` ada di `.env` file dengan format: `postgresql://user:pass@postgres:5432/db?schema=public`

## Step 6: Verify Installation

```bash
# Check containers status
docker ps

# Check logs
docker-compose -f docker-compose.prod.yaml logs -f

# Test aplikasi
curl http://localhost:3000/api/health
```

## Step 7: Setup Nginx Reverse Proxy (Optional)

Jika ingin menggunakan domain dan HTTPS:

```bash
# Install Nginx
sudo apt install nginx -y

# Create Nginx config
sudo nano /etc/nginx/sites-available/crs-trial
```

Isi dengan:

```nginx
server {
    listen 80;
    server_name your-domain.com;

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

Enable site:

```bash
sudo ln -s /etc/nginx/sites-available/crs-trial /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Maintenance Commands

### View Logs
```bash
cd /var/www/crs-trial/docker
docker-compose -f docker-compose.prod.yaml logs -f
```

### Restart Services
```bash
docker-compose -f docker-compose.prod.yaml restart
```

### Update Application
```bash
# Pull latest code (jika pakai git)
git pull

# Rebuild dan restart
docker-compose -f docker-compose.prod.yaml up -d --build app
```

### Stop Services
```bash
docker-compose -f docker-compose.prod.yaml down
```

### Backup Database
```bash
docker exec crs-trial-db-prod pg_dump -U postgres crs_trial > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore Database
```bash
cat backup.sql | docker exec -i crs-trial-db-prod psql -U postgres crs_trial
```

## Troubleshooting

### Container tidak start
```bash
# Check logs
docker-compose -f docker-compose.prod.yaml logs

# Check container status
docker ps -a
```

### Database connection error
- Pastikan PostgreSQL container sudah running
- Check DATABASE_URL di .env file
- Check network connectivity: `docker network ls`

### Port sudah digunakan
```bash
# Check port usage
sudo netstat -tulpn | grep :3000

# Atau ubah APP_PORT di .env file
```

### Permission issues
```bash
# Fix permissions
sudo chown -R $USER:$USER /var/www/crs-trial
```

## Security Best Practices

1. **Gunakan password yang kuat** untuk PostgreSQL
2. **Gunakan random SESSION_SECRET**
3. **Setup firewall** (UFW):
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```
4. **Setup SSL/HTTPS** dengan Let's Encrypt (jika pakai domain)
5. **Regular backups** database
6. **Update Docker images** secara berkala
