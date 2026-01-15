# Database Persistence & Data Protection

Dokumentasi tentang bagaimana data database dipertahankan saat deployment.

## 🔒 Perlindungan Data

### Volume Persistence

Database PostgreSQL menggunakan **Docker volume** untuk menyimpan data secara persisten:

```yaml
volumes:
  - postgres_data_prod:/var/lib/postgresql/data
```

Volume ini **tidak akan dihapus** saat:
- Container di-restart
- Container di-recreate (kecuali dengan flag `--volumes`)
- Aplikasi di-rebuild
- Code di-update

### Deployment Workflow Protection

Workflow deployment dirancang untuk **melindungi data**:

1. **PostgreSQL container tidak di-recreate**: Hanya di-ensure running
2. **Schema update aman**: `db push` akan error jika ada perubahan destructive
3. **No force reset**: Tidak menggunakan `--force-reset` yang berbahaya

## 🛡️ Cara Kerja

### Saat Deployment

1. **PostgreSQL container**: Hanya di-ensure running, tidak di-rebuild/recreate
2. **App container**: Di-rebuild dan di-restart (tidak mempengaruhi database)
3. **Schema update**: Menggunakan `db push --skip-generate` yang aman
4. **Data tetap utuh**: Volume database tidak disentuh

### Prisma db push Behavior

`prisma db push` secara default:
- ✅ **AMAN**: Akan error jika ada perubahan yang bisa menghapus data
- ✅ **Additive changes**: Menambah tabel/kolom baru = AMAN
- ✅ **Optional fields**: Menambah kolom optional = AMAN
- ❌ **Destructive changes**: Menghapus kolom/tabel = ERROR (data terlindungi)

## 📋 Contoh Perubahan Schema

### ✅ AMAN (Tidak akan menghapus data)

```prisma
// Menambah model baru
model ApiKey {
  id String @id @default(uuid())
  // ...
}

// Menambah kolom optional
model Category {
  // ... existing fields
  description String? // Optional, aman
}

// Menambah kolom dengan default value
model Category {
  // ... existing fields
  status String @default("active") // Ada default, aman
}
```

### ❌ BERBAHAYA (Akan error, data terlindungi)

```prisma
// Menghapus kolom
model Category {
  id String @id
  name String
  // active Boolean // DIHAPUS - akan error!
}

// Menghapus model
// model Category { ... } // DIHAPUS - akan error!

// Menambah required field tanpa default
model Category {
  // ... existing fields
  requiredField String // Required tanpa default - akan error!
}
```

## 🔄 Jika Perlu Perubahan Destructive

Jika Anda perlu melakukan perubahan yang bisa menghapus data:

### Opsi 1: Migration Manual (Recommended)

1. **Backup database dulu**:
   ```bash
   docker exec crs-trial-db-prod pg_dump -U postgres crs_trial > backup.sql
   ```

2. **Buat migration manual**:
   ```bash
   # Di local
   npx prisma migrate dev --name your-migration-name
   ```

3. **Deploy migration**:
   ```bash
   # Di VPS
   docker exec crs-trial npx prisma@6.1.0 migrate deploy
   ```

### Opsi 2: Data Migration Script

1. Backup data yang akan dihapus
2. Update schema
3. Restore/migrate data ke format baru

## 💾 Backup Database

### Manual Backup

```bash
# Di VPS
cd /var/www/crs-trial/docker

# Backup database
docker exec crs-trial-db-prod pg_dump -U postgres crs_trial > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker exec -i crs-trial-db-prod psql -U postgres crs_trial < backup_20240101_120000.sql
```

### Automated Backup (Optional)

Anda bisa setup cron job untuk backup otomatis:

```bash
# Edit crontab
crontab -e

# Backup setiap hari jam 2 pagi
0 2 * * * cd /var/www/crs-trial/docker && docker exec crs-trial-db-prod pg_dump -U postgres crs_trial > /backups/crs_trial_$(date +\%Y\%m\%d).sql
```

## 🔍 Verifikasi Data

### Cek Volume

```bash
# List volumes
docker volume ls | grep postgres_data_prod

# Inspect volume
docker volume inspect crs-trial_docker_postgres_data_prod

# Cek ukuran volume
du -sh /var/lib/docker/volumes/crs-trial_docker_postgres_data_prod/_data
```

### Cek Data di Database

```bash
# Connect ke database
docker exec -it crs-trial-db-prod psql -U postgres crs_trial

# Cek tables
\dt

# Cek data
SELECT COUNT(*) FROM categories;
SELECT * FROM api_keys;
```

## ⚠️ Troubleshooting

### Data Hilang Setelah Deploy?

**Kemungkinan penyebab:**

1. **Volume tidak terpasang**: Cek `docker-compose.prod.yaml` volume configuration
2. **Container di-recreate dengan `--volumes`**: Jangan gunakan flag ini
3. **Database berbeda**: Cek `DATABASE_URL` di `.env`
4. **Schema reset manual**: Jangan jalankan `prisma migrate reset` di production

**Solusi:**

```bash
# Cek volume
docker volume ls

# Cek container
docker ps -a | grep postgres

# Cek logs
docker logs crs-trial-db-prod

# Restore dari backup jika ada
```

### Schema Update Gagal?

Jika `db push` error karena perubahan destructive:

1. **Jangan gunakan `--accept-data-loss`** di production tanpa backup
2. Buat migration manual
3. Atau backup dulu, lalu gunakan `--accept-data-loss` dengan hati-hati

## 📚 Best Practices

1. ✅ **Selalu backup** sebelum perubahan schema besar
2. ✅ **Gunakan migration** untuk perubahan production
3. ✅ **Test di development** dulu sebelum deploy
4. ✅ **Monitor volume** untuk memastikan data tersimpan
5. ❌ **Jangan gunakan `--force-reset`** di production
6. ❌ **Jangan recreate postgres container** dengan `--volumes`

## 🔗 Related Documentation

- [API Keys Documentation](./api-keys.md)
- [Deployment Guide](../docker/DEPLOYMENT.md)
- [Prisma Migrations](https://www.prisma.io/docs/guides/migrate)