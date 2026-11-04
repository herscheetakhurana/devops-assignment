#!/usr/bin/env bash
# ============================================================
# Git Setup & GitHub Push Script
# Run this on Ubuntu/Linux to push the project to GitHub
# Usage: bash scripts/git-push-to-github.sh <github-username> <repo-name>
# ============================================================
set -euo pipefail

GITHUB_USER="${1:-your-github-username}"
REPO_NAME="${2:-devops-assignment}"
REMOTE_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo "============================================"
echo "  DevOps Assignment - Git Push to GitHub"
echo "============================================"
echo "GitHub User : $GITHUB_USER"
echo "Repository  : $REPO_NAME"
echo "Remote URL  : $REMOTE_URL"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "[ERROR] Git is not installed."
    echo "        Run: sudo apt-get install -y git"
    exit 1
fi

# Configure git if not already set
if [ -z "$(git config --global user.name 2>/dev/null)" ]; then
    echo "[INFO] Git user not configured. Setting up..."
    read -rp "Enter your full name : " GIT_NAME
    read -rp "Enter your email     : " GIT_EMAIL
    git config --global user.name  "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
fi

git config --global init.defaultBranch main
git config --global core.autocrlf input

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"
echo "[INFO] Working directory: $(pwd)"
echo ""

# Step 1: Init repo
if [ ! -d ".git" ]; then
    echo "[1/5] Initialising git repository..."
    git init
else
    echo "[1/5] Git repository already initialised."
fi

# Step 2: Stage all files
echo "[2/5] Staging all files..."
git add -A

# Step 3: Commit
if git diff --cached --quiet; then
    echo "[3/5] Nothing new to commit — working tree clean."
else
    echo "[3/5] Creating commit..."
    git commit -m "feat: complete devops assignment - all 4 labs

Lab 1: Git workflow, Jenkins declarative pipeline, GitHub webhook CI
Lab 2: Docker multi-stage build, Docker Compose, Kubernetes + HPA
Lab 3: Ansible provisioning, Terraform IaC, Prometheus+Grafana,
        ELK stack logging, Trivy security scanning
Lab 4: Blue-Green & Canary deployments, GitOps/ArgoCD,
        HashiCorp Vault secrets, Disaster Recovery"
fi

# Step 4: Set remote
echo "[4/5] Configuring remote origin..."
if git remote get-url origin &>/dev/null 2>&1; then
    git remote set-url origin "$REMOTE_URL"
    echo "      Updated existing remote."
else
    git remote add origin "$REMOTE_URL"
    echo "      Added new remote."
fi

# Step 5: Push
echo "[5/5] Pushing to GitHub..."
echo ""
echo "  NOTE: Use a Personal Access Token (PAT) as the password."
echo "  Create one at: GitHub -> Settings -> Developer settings"
echo "                 -> Personal access tokens -> Tokens (classic)"
echo "  Required scope: repo (full control)"
echo ""
git branch -M main
git push -u origin main

echo ""
echo "============================================"
echo "  Push complete!"
echo "  View at: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "============================================"
