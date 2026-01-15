#!/bin/bash

# Script untuk generate .env file untuk production
# Usage: ./setup-env.sh [DOMAIN_OR_IP]

set -e

echo "=== CRS Trial - Environment Setup ==="
echo ""

# Get domain or IP
if [ -z "$1" ]; then
    # Try to get IP automatically
    VPS_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")
    echo "No domain/IP provided, using: $VPS_IP"
    APP_URL="http://$VPS_IP:3000"
else
    if [[ "$1" == http* ]]; then
        APP_URL="$1"
    else
        APP_URL="http://$1:3000"
    fi
    echo "Using URL: $APP_URL"
fi

# Generate secure values
echo ""
echo "Generating secure passwords and secrets..."
POSTGRES_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-20)
SESSION_SECRET=$(openssl rand -base64 32)

# Ask for HTTPS
echo ""
read -p "Are you using HTTPS? (y/n) [n]: " USE_HTTPS
USE_HTTPS=${USE_HTTPS:-n}

if [[ "$USE_HTTPS" == "y" || "$USE_HTTPS" == "Y" ]]; then
    COOKIE_SECURE="true"
    if [[ "$APP_URL" == http://* ]]; then
        APP_URL=$(echo "$APP_URL" | sed 's/http:/https:/')
    fi
else
    COOKIE_SECURE="false"
fi

# Create .env file
cat > .env << EOF
# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=crs_trial
POSTGRES_PORT=5432

# Application Configuration
APP_PORT=3000
SESSION_SECRET=$SESSION_SECRET
NEXT_PUBLIC_APP_URL=$APP_URL
COOKIE_SECURE=$COOKIE_SECURE
NODE_ENV=production
EOF

echo ""
echo "✅ .env file created successfully!"
echo ""
echo "📋 Generated values (SAVE THESE!):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Session Secret:      $SESSION_SECRET"
echo "App URL:             $APP_URL"
echo "Cookie Secure:       $COOKIE_SECURE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANT: Save these values in a secure location!"
echo ""
echo "Next steps:"
echo "  1. Review .env file: cat .env"
echo "  2. Start deployment: ./deploy.sh start"
echo "  3. Setup database: ./deploy.sh setup-db"
echo ""
