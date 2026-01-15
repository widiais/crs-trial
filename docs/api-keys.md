# API Key Management

Dokumentasi ini menjelaskan cara menggunakan API Key untuk mengakses API dari aplikasi eksternal.

## 📋 Overview

API Key memungkinkan aplikasi eksternal untuk mengakses API tanpa perlu login melalui session. Sistem ini mendukung:
- **Session-based auth**: Untuk aplikasi web (dashboard)
- **API Key auth**: Untuk aplikasi eksternal (mobile apps, third-party integrations, dll)

## 🔑 Membuat API Key

### Via API Endpoint

**Endpoint**: `POST /api/api-keys`

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "name": "Mobile App Production",
  "expiresAt": "2025-12-31T23:59:59Z" // Optional, bisa null untuk tidak expire
}
```

**Response** (201 Created):
```json
{
  "id": "uuid-here",
  "name": "Mobile App Production",
  "key": "crs_abc123def456...",
  "active": true,
  "expiresAt": "2025-12-31T23:59:59Z",
  "createdAt": "2024-01-01T00:00:00Z",
  "message": "⚠️ Simpan API key ini dengan baik! Key ini tidak akan ditampilkan lagi."
}
```

⚠️ **PENTING**: Simpan API key (`key`) dengan baik! Key ini hanya ditampilkan sekali saat dibuat dan tidak akan ditampilkan lagi di endpoint lain.

### Via Dashboard (Coming Soon)

Anda juga bisa membuat API key melalui dashboard aplikasi (jika sudah dibuat UI-nya).

## 📝 Menggunakan API Key

### Format 1: X-API-Key Header (Recommended)

```bash
curl -X GET https://yourdomain.com/api/categories \
  -H "X-API-Key: crs_abc123def456..."
```

### Format 2: Authorization Bearer Header

```bash
curl -X GET https://yourdomain.com/api/categories \
  -H "Authorization: Bearer crs_abc123def456..."
```

### Contoh dengan JavaScript/Fetch

```javascript
// Menggunakan X-API-Key header
const response = await fetch('https://yourdomain.com/api/categories', {
  headers: {
    'X-API-Key': 'crs_abc123def456...',
    'Content-Type': 'application/json'
  }
});

// Atau menggunakan Authorization Bearer
const response = await fetch('https://yourdomain.com/api/categories', {
  headers: {
    'Authorization': 'Bearer crs_abc123def456...',
    'Content-Type': 'application/json'
  }
});
```

### Contoh dengan Python

```python
import requests

# Menggunakan X-API-Key header
headers = {
    'X-API-Key': 'crs_abc123def456...',
    'Content-Type': 'application/json'
}

response = requests.get('https://yourdomain.com/api/categories', headers=headers)

# Atau menggunakan Authorization Bearer
headers = {
    'Authorization': 'Bearer crs_abc123def456...',
    'Content-Type': 'application/json'
}

response = requests.get('https://yourdomain.com/api/categories', headers=headers)
```

## 📊 Mengelola API Keys

### List Semua API Keys

**Endpoint**: `GET /api/api-keys`

**Headers**: 
- Harus login via session (untuk keamanan)

**Response**:
```json
[
  {
    "id": "uuid-1",
    "name": "Mobile App Production",
    "active": true,
    "lastUsedAt": "2024-01-15T10:30:00Z",
    "expiresAt": "2025-12-31T23:59:59Z",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  },
  {
    "id": "uuid-2",
    "name": "Test Integration",
    "active": false,
    "lastUsedAt": null,
    "expiresAt": null,
    "createdAt": "2024-01-10T00:00:00Z",
    "updatedAt": "2024-01-10T00:00:00Z"
  }
]
```

**Note**: API key yang sebenarnya (`key`) tidak ditampilkan untuk keamanan.

### Deactivate/Activate API Key

**Endpoint**: `PATCH /api/api-keys`

**Body**:
```json
{
  "id": "uuid-here",
  "active": false  // true untuk activate, false untuk deactivate
}
```

### Delete API Key

**Endpoint**: `DELETE /api/api-keys?id=<uuid>`

**Response**:
```json
{
  "success": true,
  "message": "API key deleted"
}
```

## 🔒 Keamanan

1. **Jangan commit API key ke Git**: Simpan di environment variables atau secret management
2. **Gunakan HTTPS**: Selalu gunakan HTTPS saat mengirim API key
3. **Rotate keys**: Ganti API key secara berkala, terutama jika dicurigai bocor
4. **Set expiry**: Gunakan `expiresAt` untuk membatasi masa aktif API key
5. **Monitor usage**: Cek `lastUsedAt` untuk melihat aktivitas API key

## 📡 Endpoints yang Support API Key

Semua endpoint API yang menggunakan `isAuthenticatedOrHasApiKey()` akan support API key:

- ✅ `GET /api/categories` - List categories
- ✅ `POST /api/categories` - Create category
- ✅ `PUT /api/categories` - Update category
- ✅ `DELETE /api/categories` - Delete category
- ❌ `GET /api/api-keys` - Hanya via session (untuk keamanan)
- ❌ `POST /api/api-keys` - Hanya via session (untuk keamanan)
- ❌ `DELETE /api/api-keys` - Hanya via session (untuk keamanan)

## 🚨 Error Responses

### 401 Unauthorized

```json
{
  "error": "Unauthorized"
}
```

**Kemungkinan penyebab**:
- API key tidak valid
- API key sudah expired
- API key sudah di-deactivate
- Header tidak dikirim dengan benar

### 400 Bad Request

```json
{
  "error": "Validation error",
  "details": [...]
}
```

## 🔄 Migration & Setup

Setelah menambahkan model ApiKey ke Prisma schema:

1. **Generate Prisma Client**:
   ```bash
   npm run db:generate
   ```

2. **Run Migration**:
   ```bash
   npm run db:migrate
   ```

   Atau jika menggunakan `db push`:
   ```bash
   npm run db:push
   ```

3. **Test API Key**:
   - Login ke dashboard
   - Create API key via `POST /api/api-keys`
   - Test dengan curl atau Postman

## 📚 Contoh Lengkap

### 1. Create API Key

```bash
# Login dulu (untuk mendapatkan session)
curl -X POST https://yourdomain.com/api/auth/login \
  -c cookies.txt

# Create API key
curl -X POST https://yourdomain.com/api/api-keys \
  -b cookies.txt \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Mobile App",
    "expiresAt": null
  }'
```

### 2. Use API Key

```bash
# Simpan API key yang didapat
API_KEY="crs_abc123def456..."

# Gunakan untuk akses API
curl -X GET https://yourdomain.com/api/categories \
  -H "X-API-Key: $API_KEY"
```

### 3. List Categories dengan API Key

```bash
curl -X GET https://yourdomain.com/api/categories \
  -H "X-API-Key: crs_abc123def456..." \
  -H "Content-Type: application/json"
```

### 4. Create Category dengan API Key

```bash
curl -X POST https://yourdomain.com/api/categories \
  -H "X-API-Key: crs_abc123def456..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Category",
    "active": true
  }'
```

## 🎯 Best Practices

1. **Naming Convention**: Gunakan nama yang deskriptif untuk API key (contoh: "Mobile App - Production", "Third Party Integration - Staging")
2. **Environment-based**: Buat API key terpisah untuk development, staging, dan production
3. **Least Privilege**: Buat API key dengan akses minimal yang diperlukan
4. **Monitoring**: Monitor `lastUsedAt` untuk mendeteksi aktivitas mencurigakan
5. **Documentation**: Dokumentasikan di mana API key digunakan untuk memudahkan tracking

## ❓ FAQ

**Q: Apakah API key bisa digunakan untuk semua endpoint?**  
A: Tidak, endpoint untuk manage API keys (`/api/api-keys`) hanya bisa diakses via session untuk keamanan.

**Q: Bagaimana cara reset API key yang hilang?**  
A: Delete API key yang lama dan buat yang baru. API key yang sebenarnya tidak bisa di-retrieve lagi setelah dibuat.

**Q: Apakah API key expire otomatis?**  
A: Ya, jika `expiresAt` di-set. Setelah expire, API key tidak bisa digunakan lagi.

**Q: Bisa tidak menggunakan API key tanpa expiry?**  
A: Bisa, set `expiresAt` ke `null` saat create API key.

**Q: Apakah API key di-hash di database?**  
A: Ya, API key di-hash menggunakan SHA-256 sebelum disimpan di database untuk keamanan.