# GitHub Actions Workflows

## Deploy to VPS

Workflow ini akan otomatis deploy aplikasi ke VPS setiap ada push ke branch `main`.

### Setup

#### 1. Generate SSH Key untuk GitHub Actions

Di VPS, generate SSH key khusus untuk deployment:

```bash
# Di VPS
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_deploy
```

**Jangan set passphrase** (biarkan kosong saat diminta).

#### 2. Setup SSH Key di VPS

```bash
# Di VPS
# Copy public key ke authorized_keys
cat ~/.ssh/github_actions_deploy.pub >> ~/.ssh/authorized_keys

# Set correct permissions
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# Copy private key (akan digunakan di GitHub Secrets)
cat ~/.ssh/github_actions_deploy
```

**⚠️ PENTING:** Copy output dari `cat ~/.ssh/github_actions_deploy` (private key) - ini akan digunakan di GitHub Secrets.

#### 3. Setup GitHub Secrets

Di GitHub repository, buka:
**Settings → Secrets and variables → Actions → New repository secret**

Tambahkan secrets berikut:

1. **VPS_SSH_PRIVATE_KEY**
   - Value: Private key yang di-copy dari VPS (seluruh isi file, termasuk `-----BEGIN OPENSSH PRIVATE KEY-----` dan `-----END OPENSSH PRIVATE KEY-----`)

2. **VPS_HOST**
   - Value: IP address atau domain VPS (contoh: `123.456.789.0` atau `vps.example.com`)

3. **VPS_USER**
   - Value: Username untuk SSH (biasanya `root` atau username VPS)

4. **VPS_URL** (optional)
   - Value: URL aplikasi (contoh: `http://yourdomain.com:3000`)

#### 4. Test Deployment

Setelah setup, test dengan:
- Push ke branch `main`, atau
- Manual trigger: **Actions → Deploy to VPS → Run workflow**

### Workflow Steps

1. **Checkout code** - Download code dari repository
2. **Setup SSH** - Setup SSH connection ke VPS
3. **Deploy to VPS** - SSH ke VPS dan:
   - Pull latest code
   - Rebuild Docker containers
   - Restart services
   - Setup database schema
   - Health check

### Troubleshooting

#### SSH Connection Failed
- Pastikan SSH key sudah di-setup dengan benar
- Pastikan VPS_HOST dan VPS_USER benar
- Cek firewall tidak block SSH port (22)

#### Deployment Failed
- Cek logs di GitHub Actions
- SSH manual ke VPS dan cek logs: `docker logs crs-trial`
- Pastikan `.env` file ada di `/var/www/crs-trial/docker/`

#### Container Not Starting
- Cek environment variables: `docker exec crs-trial env`
- Cek database connection
- View logs: `docker logs crs-trial`
