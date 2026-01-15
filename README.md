# CRS Trial - CRUD Application

Aplikasi CRUD sederhana untuk pembelajaran hosting VPS menggunakan Next.js, Prisma, PostgreSQL, dan Docker.

## Tech Stack

- Next.js 15.5.9
- React 19.2.3
- TypeScript 5
- Prisma 6.1.0
- PostgreSQL 15
- Tailwind CSS 3.4.1
- Docker

## Setup Development

1. Install dependencies:
```bash
npm install
```

2. Setup environment variables:
```bash
cp .env.example .env
```

Edit `.env` dan sesuaikan `DATABASE_URL` jika perlu.

3. Start PostgreSQL dengan Docker:
```bash
cd docker
docker-compose up -d postgres
```

4. Setup database:
```bash
npx prisma generate
npx prisma db push
```

5. Run development server:
```bash
npm run dev
```

Aplikasi akan berjalan di `http://localhost:3000`

## Docker Development

Untuk menjalankan seluruh stack dengan Docker:

```bash
cd docker
docker-compose up
```

## Production Build

1. Build aplikasi:
```bash
npm run build
```

2. Run production server:
```bash
npm start
```

## Docker Production (Full Stack)

Untuk menjalankan aplikasi lengkap dengan Docker di VPS:

### 1. Setup Environment Variables

Buat file `.env` di folder `docker/`:

```bash
cd docker
cat > .env << EOF
# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-secure-password-here
POSTGRES_DB=crs_trial
POSTGRES_PORT=5432

# Application Configuration
APP_PORT=3000
SESSION_SECRET=your-very-secure-secret-key-here
NEXT_PUBLIC_APP_URL=http://your-domain.com
EOF
```

**PENTING**: Ganti password dan secret key dengan nilai yang aman!

### 2. Build dan Run dengan Docker Compose

```bash
cd docker
docker-compose -f docker-compose.prod.yaml --env-file .env up -d --build
```

Ini akan:
- Build Next.js app dengan Dockerfile.prod
- Start PostgreSQL container
- Start Next.js app container
- Setup network antara containers
- Run semua di background mode

### 3. Check Status

```bash
# Check running containers
docker ps

# Check logs
docker-compose -f docker-compose.prod.yaml logs -f

# Check specific service logs
docker-compose -f docker-compose.prod.yaml logs -f app
docker-compose -f docker-compose.prod.yaml logs -f postgres
```

### 4. Stop Services

```bash
cd docker
docker-compose -f docker-compose.prod.yaml down
```

### 5. Update Application

```bash
cd docker
docker-compose -f docker-compose.prod.yaml up -d --build app
```

## Deployment di VPS Hostinger

### Prerequisites di VPS:
- Docker dan Docker Compose terinstall
- Port 3000 (atau port yang diinginkan) terbuka
- Domain sudah diarahkan ke IP VPS (optional)

### Langkah Deployment:

1. **Upload code ke VPS**:
```bash
# Di local machine
scp -r crs-trial/ user@your-vps-ip:/path/to/destination/
```

2. **SSH ke VPS**:
```bash
ssh user@your-vps-ip
cd /path/to/crs-trial/docker
```

3. **Setup environment**:
```bash
# Buat .env file dengan konfigurasi production
nano .env
```

4. **Start aplikasi**:
```bash
docker-compose -f docker-compose.prod.yaml --env-file .env up -d --build
```

5. **Setup reverse proxy (Nginx - optional)**:
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
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Maintenance Commands:

```bash
# Restart semua services
docker-compose -f docker-compose.prod.yaml restart

# Restart specific service
docker-compose -f docker-compose.prod.yaml restart app

# View logs
docker-compose -f docker-compose.prod.yaml logs -f

# Stop semua
docker-compose -f docker-compose.prod.yaml down

# Stop dan hapus volumes (HATI-HATI: akan hapus data!)
docker-compose -f docker-compose.prod.yaml down -v
```

## Features

- Login sederhana (tanpa autentikasi real)
- Dashboard
- Setup Categories dengan CRUD lengkap:
  - Create category
  - Read/List categories
  - Update category
  - Delete category
  - Toggle active/inactive status

## Database Schema

### Category
- `id` (UUID)
- `name` (String)
- `active` (Boolean)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)
