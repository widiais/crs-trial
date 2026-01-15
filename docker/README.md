# Docker Configuration

Folder ini berisi konfigurasi Docker untuk development dan production.

## Files

- `docker-compose.yaml` - Development setup (dengan hot reload)
- `docker-compose.prod.yaml` - Production setup (optimized build)
- `Dockerfile.dev` - Development Dockerfile
- `Dockerfile.prod` - Production Dockerfile (multi-stage build)
- `deploy.sh` - Helper script untuk deployment
- `DEPLOYMENT.md` - Panduan lengkap deployment ke VPS

## Quick Start

### Development

```bash
# Start PostgreSQL only
docker-compose up -d postgres

# Start full stack (PostgreSQL + Next.js app)
docker-compose up
```

### Production

1. Setup environment variables:
```bash
# Menggunakan setup script (recommended)
./setup-env.sh your-domain.com

# Atau manual
nano .env
```

2. Deploy:
```bash
./deploy.sh start
./deploy.sh setup-db
```

**Required Environment Variables:**
- `POSTGRES_PASSWORD` - Database password (required)
- `SESSION_SECRET` - Session encryption key (required)
- `NEXT_PUBLIC_APP_URL` - Application URL (required)
- `COOKIE_SECURE` - Set to "false" for HTTP, "true" for HTTPS (default: false)

## Commands

Gunakan `deploy.sh` script untuk kemudahan:

```bash
./deploy.sh start      # Start semua services
./deploy.sh stop       # Stop semua services
./deploy.sh restart    # Restart semua services
./deploy.sh logs       # View logs
./deploy.sh update     # Update app container
./deploy.sh status     # Check status
./deploy.sh setup-db   # Setup database schema
```

Atau gunakan docker-compose langsung:

```bash
# Production
docker-compose -f docker-compose.prod.yaml --env-file .env up -d --build

# Development
docker-compose up
```

## Network

Containers berkomunikasi melalui Docker network `crs-trial-network`. App container bisa akses PostgreSQL dengan hostname `postgres`.

## Volumes

- `postgres_data_prod` - PostgreSQL data persistence (production)
- `postgres_data` - PostgreSQL data persistence (development)

## Ports

- `3000` - Next.js application
- `5432` - PostgreSQL database

## Health Checks

Kedua containers memiliki health checks:
- PostgreSQL: `pg_isready`
- Next.js App: `/api/health` endpoint
