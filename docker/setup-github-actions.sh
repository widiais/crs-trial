#!/bin/bash

# Script untuk setup GitHub Actions deployment
# Usage: ./setup-github-actions.sh

set -e

echo "=== GitHub Actions Deployment Setup ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ] && [ "$USER" != "root" ]; then
    echo "⚠️  Running as non-root user. Some commands may need sudo."
fi

# Generate SSH key
echo "🔑 Generating SSH key for GitHub Actions..."
SSH_KEY_PATH="$HOME/.ssh/github_actions_deploy"

if [ -f "$SSH_KEY_PATH" ]; then
    echo "⚠️  SSH key already exists at $SSH_KEY_PATH"
    read -p "Do you want to overwrite? (y/n) [n]: " OVERWRITE
    OVERWRITE=${OVERWRITE:-n}
    if [[ "$OVERWRITE" != "y" && "$OVERWRITE" != "Y" ]]; then
        echo "Skipping SSH key generation..."
        USE_EXISTING=true
    else
        rm -f "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"
        USE_EXISTING=false
    fi
else
    USE_EXISTING=false
fi

if [ "$USE_EXISTING" = false ]; then
    ssh-keygen -t ed25519 -C "github-actions-deploy" -f "$SSH_KEY_PATH" -N ""
    echo "✅ SSH key generated!"
fi

# Add to authorized_keys
echo ""
echo "📝 Adding public key to authorized_keys..."
if [ -f "$HOME/.ssh/authorized_keys" ]; then
    # Check if key already exists
    if grep -q "$(cat $SSH_KEY_PATH.pub)" "$HOME/.ssh/authorized_keys" 2>/dev/null; then
        echo "✅ Public key already in authorized_keys"
    else
        cat "$SSH_KEY_PATH.pub" >> "$HOME/.ssh/authorized_keys"
        echo "✅ Public key added to authorized_keys"
    fi
else
    mkdir -p "$HOME/.ssh"
    cat "$SSH_KEY_PATH.pub" > "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"
    chmod 700 "$HOME/.ssh"
    echo "✅ Created authorized_keys file"
fi

# Display private key
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PRIVATE KEY (Copy this to GitHub Secrets → VPS_SSH_PRIVATE_KEY):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$SSH_KEY_PATH"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get VPS info
echo "📝 VPS Information needed for GitHub Secrets:"
echo ""
VPS_HOST=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "")
VPS_USER=$(whoami)

echo "VPS_HOST: $VPS_HOST (or your domain)"
echo "VPS_USER: $VPS_USER"
echo ""

# Instructions
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Go to GitHub repository: Settings → Secrets and variables → Actions"
echo ""
echo "2. Add these secrets:"
echo ""
echo "   VPS_SSH_PRIVATE_KEY:"
echo "   (Copy the private key shown above)"
echo ""
echo "   VPS_HOST:"
echo "   $VPS_HOST (or your domain)"
echo ""
echo "   VPS_USER:"
echo "   $VPS_USER"
echo ""
echo "   VPS_URL (optional):"
echo "   http://$VPS_HOST:3000 (or your domain)"
echo ""
echo "3. Push to main branch to trigger deployment"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
