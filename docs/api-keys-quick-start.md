# API Keys - Quick Start Guide

Panduan cepat untuk menggunakan API Key di aplikasi ini.

## 🚀 Setup Awal

### 1. Update Database Schema

```bash
# Generate Prisma client dengan model ApiKey baru
npm run db:generate

# Push schema ke database (atau migrate)
npm run db:push
# atau
npm run db:migrate
```

### 2. Create API Key Pertama

**Via cURL**:
```bash
# 1. Login dulu untuk mendapatkan session
curl -X POST http://localhost:3000/api/auth/login -c cookies.txt

# 2. Create API key
curl -X POST http://localhost:3000/api/api-keys \
  -b cookies.txt \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My First API Key",
    "expiresAt": null
  }'
```

**Response**:
```json
{
  "id": "...",
  "name": "My First API Key",
  "key": "crs_abc123def456...",  // ⚠️ SIMPAN INI!
  "active": true,
  "expiresAt": null,
  "createdAt": "...",
  "message": "⚠️ Simpan API key ini dengan baik!"
}
```

### 3. Gunakan API Key

```bash
# Simpan API key
export API_KEY="crs_abc123def456..."

# Test akses API
curl -X GET http://localhost:3000/api/categories \
  -H "X-API-Key: $API_KEY"
```

## 📝 Format Request

### Option 1: X-API-Key Header (Recommended)
```
X-API-Key: crs_abc123def456...
```

### Option 2: Authorization Bearer
```
Authorization: Bearer crs_abc123def456...
```

## 🔧 Endpoints

| Endpoint | Method | Auth | Deskripsi |
|----------|--------|------|-----------|
| `/api/api-keys` | GET | Session | List semua API keys |
| `/api/api-keys` | POST | Session | Create API key baru |
| `/api/api-keys` | PATCH | Session | Activate/Deactivate API key |
| `/api/api-keys` | DELETE | Session | Delete API key |
| `/api/categories` | GET | Session/API Key | List categories |
| `/api/categories` | POST | Session/API Key | Create category |
| `/api/categories` | PUT | Session/API Key | Update category |
| `/api/categories` | DELETE | Session/API Key | Delete category |

## 💡 Contoh Kode

### JavaScript/TypeScript
```typescript
const apiKey = 'crs_abc123def456...';

// Fetch categories
const response = await fetch('http://localhost:3000/api/categories', {
  headers: {
    'X-API-Key': apiKey,
    'Content-Type': 'application/json'
  }
});

const categories = await response.json();
```

### Python
```python
import requests

api_key = 'crs_abc123def456...'

headers = {
    'X-API-Key': api_key,
    'Content-Type': 'application/json'
}

response = requests.get('http://localhost:3000/api/categories', headers=headers)
categories = response.json()
```

### cURL
```bash
curl -X GET http://localhost:3000/api/categories \
  -H "X-API-Key: crs_abc123def456..."
```

## ⚠️ Important Notes

1. **Simpan API key dengan baik** - Key hanya ditampilkan sekali saat dibuat
2. **Gunakan HTTPS** di production
3. **Jangan commit API key** ke Git
4. **Set expiry date** untuk keamanan tambahan
5. **Monitor usage** via `lastUsedAt` field

## 📚 Dokumentasi Lengkap

Lihat [api-keys.md](./api-keys.md) untuk dokumentasi lengkap.