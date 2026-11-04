# Contributing & GitHub Setup Guide

This document explains how to initialise the Git repository and push this project to GitHub.

---

## Prerequisites

Make sure the following tools are installed on your **Ubuntu 24.04 LTS** machine:

```bash
# Install Git
sudo apt-get update && sudo apt-get install -y git

# Verify
git --version    # git version 2.43.x
```

---

## Step 1 — Create the GitHub Repository

1. Go to [https://github.com/new](https://github.com/new)
2. Set:
   - **Repository name**: `devops-assignment`
   - **Visibility**: Public (or Private)
   - **Do NOT** initialise with README, .gitignore, or licence (the repo already has these)
3. Click **Create repository**
4. Copy the HTTPS URL shown (e.g. `https://github.com/YOUR-USERNAME/devops-assignment.git`)

---

## Step 2 — Create a Personal Access Token (PAT)

GitHub no longer accepts passwords for HTTPS pushes. Use a PAT instead.

1. Go to: **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**
2. Click **Generate new token (classic)**
3. Set:
   - **Note**: `devops-assignment push`
   - **Expiration**: 30 days
   - **Scopes**: ✅ `repo` (full control of private repositories)
4. Click **Generate token**
5. **Copy the token immediately** — you will not see it again

---

## Step 3 — Push to GitHub (Automated Script)

The easiest way is to use the provided script:

```bash
# From the project root on Ubuntu
bash scripts/git-push-to-github.sh YOUR-GITHUB-USERNAME devops-assignment
```

When prompted for a password, paste your **Personal Access Token** (not your GitHub password).

---

## Step 4 — Push to GitHub (Manual Commands)

If you prefer to run the steps manually:

```bash
# Navigate to the project root
cd ~/devops-assignment

# Configure your Git identity (first time only)
git config --global user.name  "Your Name"
git config --global user.email "your@email.com"
git config --global init.defaultBranch main

# Initialise the repository
git init

# Stage everything
git add -A

# Create the initial commit
git commit -m "feat: complete devops assignment - all 4 labs

Lab 1: Git workflow, Jenkins CI/CD pipeline, GitHub webhook integration
Lab 2: Docker multi-stage build, Docker Compose, Kubernetes + HPA
Lab 3: Ansible, Terraform, Prometheus+Grafana, ELK stack, Trivy
Lab 4: Blue-Green & Canary deployments, ArgoCD GitOps, Vault, DR"

# Add the remote (replace YOUR-USERNAME)
git remote add origin https://github.com/YOUR-USERNAME/devops-assignment.git

# Push
git branch -M main
git push -u origin main
```

---

## Commit Convention

All commits in this project follow [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | When to use |
|--------|-------------|
| `feat:` | New feature or experiment added |
| `fix:` | Bug fix |
| `docs:` | Documentation only changes |
| `config:` | Configuration changes (Jenkinsfile, Dockerfile, etc.) |
| `ci:` | CI/CD pipeline changes |
| `chore:` | Maintenance tasks (dependency updates, etc.) |

**Examples:**
```bash
git commit -m "feat: add HPA manifest for lab2 kubernetes"
git commit -m "fix: correct prometheus scrape interval"
git commit -m "docs: complete lab3 monitoring report"
git commit -m "ci: add trivy scan to GitHub Actions workflow"
```

---

## Branch Strategy

```
main        ← stable, production-ready
develop     ← integration branch
lab/lab1    ← feature branch for lab 1 work
lab/lab2    ← feature branch for lab 2 work
```

---

## After Pushing

Once pushed, verify on GitHub:
- All 4 lab folders visible
- `.github/workflows/ci.yml` triggers the **CI Pipeline** action
- README renders correctly
- No secrets or `.env` files committed (check `.gitignore`)

The GitHub Actions CI pipeline will automatically:
1. Install Node.js dependencies
2. Run Jest unit tests
3. Build the Docker image
4. Run a Trivy security scan
5. Push to Docker Hub (on `main` branch only — requires secrets configured)

To configure Docker Hub secrets in GitHub:
**Repository → Settings → Secrets and variables → Actions → New repository secret**
- `DOCKER_USERNAME` — your Docker Hub username
- `DOCKER_PASSWORD` — your Docker Hub access token
