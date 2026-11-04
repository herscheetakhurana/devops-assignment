#!/usr/bin/env bash
# ============================================================
# Lab 1 - Environment Setup Script
# OS: Ubuntu 24.04 LTS
# ============================================================
set -euo pipefail

echo "======================================"
echo " Lab 1: Environment Setup"
echo "======================================"

# Update system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Git
echo "[1/5] Installing Git..."
sudo apt-get install -y git curl wget gnupg2 ca-certificates
git --version

# Install Node.js 20.x (LTS)
echo "[2/5] Installing Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version && npm --version

# Install Java (Jenkins dependency)
echo "[3/5] Installing Java 17..."
sudo apt-get install -y openjdk-17-jdk
java -version

# Install Jenkins
echo "[4/5] Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
    sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | \
    sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update && sudo apt-get install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
echo "Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Configure Git globals
echo "[5/5] Configuring Git..."
git config --global init.defaultBranch main
git config --global core.autocrlf input

echo ""
echo "======================================"
echo " Setup Complete!"
echo " Jenkins URL: http://localhost:8080"
echo "======================================"
