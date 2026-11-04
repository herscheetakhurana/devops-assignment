# Lab 1 Report: DevOps Foundations & Continuous Integration

## Student Information
- **Name**: Elari
- **Date**: November 2026
- **Environment**: Ubuntu 24.04 LTS (VM via VirtualBox / WSL2 on Windows 11)
- **Repository**: https://github.com/elari-dev/devops-assignment

---

## Experiment 1: Git & GitHub Setup

### Objective
Install Git, configure global identity, initialise a local repository, and push to GitHub.

### Steps Performed
1. Updated system packages with `sudo apt-get update -y && sudo apt-get upgrade -y`
2. Installed Git using `sudo apt-get install -y git`
3. Configured global user identity (name & email)
4. Initialised local repository with `git init`
5. Created `.gitignore` to exclude `node_modules/`, `coverage/`, and build artefacts
6. Created a GitHub repository named `devops-assignment`
7. Added remote origin and pushed the first commit



### Commands Executed
```bash
# Install and verify Git
sudo apt-get update -y && sudo apt-get install -y git
git --version          # git version 2.43.0

# Configure identity
git config --global user.name  "Elari"
git config --global user.email "elari@example.com"
git config --global init.defaultBranch main
git config --global core.autocrlf input

# Initialise repository
cd ~/devops-assignment
git init
git add .
git commit -m "feat: initial project setup with all 4 lab structures"

# Link to GitHub and push
git remote add origin https://github.com/elari-dev/devops-assignment.git
git branch -M main
git push -u origin main
```

### Observations
- **Git version installed**: 2.43.0
- **Repository URL**: https://github.com/elari-dev/devops-assignment
- First push was successful; GitHub showed all 4 lab folders and the `app/` directory correctly
- `.gitignore` at the project root ensured `node_modules/` was excluded from tracking
- Commit message followed conventional-commit format (`feat:`)

### Key Learning
Git's distributed nature means the full commit history lives locally. The remote on GitHub is simply another clone used as the "source of truth" for the team.

---

## Experiment 2: Node.js Application Setup

### Objective
Set up the Node.js Express sample application and verify it runs correctly.

### Steps Performed
1. Installed Node.js 20.x LTS via NodeSource setup script
2. Installed application dependencies with `npm ci`
3. Ran the test suite with `npm test`
4. Started the development server and verified all endpoints

### Commands Executed
```bash
# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version   # v20.18.0
npm  --version   # 10.8.2

# Install app dependencies
cd ~/devops-assignment/app
npm ci

# Run tests
npm test
# PASS  server.test.js
#   GET /health
#     ✓ should return 200 with healthy status (42 ms)
#   GET /api/info
#     ✓ should return app info (8 ms)
# Tests: 2 passed, 2 total

# Start server and test endpoints
npm start &
curl http://localhost:3000/health
# {"status":"healthy","uptime":2.1,"timestamp":"2026-11-02T06:00:00.000Z"}
curl http://localhost:3000/api/info
# {"app":"devops-sample-app","version":"1.0.0","environment":"production"}
```

### Observations
- Node.js v20.18.0 and npm 10.8.2 installed successfully
- All 2 unit tests passed on first run
- `/health` endpoint returns correct JSON with uptime and timestamp
- `/api/info` endpoint reflects environment variables correctly

---

## Experiment 3: Jenkins Installation & Configuration

### Objective
Install Jenkins on Ubuntu 24.04, complete the initial setup, and configure the NodeJS plugin.

### Steps Performed
1. Installed Java 17 (OpenJDK) — required by Jenkins
2. Added Jenkins apt repository and GPG key
3. Installed Jenkins and started the service
4. Retrieved the initial admin password and completed setup wizard
5. Installed plugins: Git, Pipeline, GitHub Integration, NodeJS, JUnit, HTML Publisher, Blue Ocean
6. Configured NodeJS 20.x as a global tool in Jenkins
7. Created a Pipeline job pointing to the GitHub repository

### Commands Executed
```bash
# Install Java 17
sudo apt-get install -y openjdk-17-jdk
java -version    # openjdk version "17.0.12"

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
    sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/" | \
    sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install and start Jenkins
sudo apt-get update && sudo apt-get install -y jenkins
sudo systemctl start jenkins && sudo systemctl enable jenkins
sudo systemctl status jenkins   # active (running)

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Observations
- **Jenkins version**: 2.479.1 (LTS)
- **Java version**: OpenJDK 17.0.12
- Jenkins accessible at `http://localhost:8080` within 30 seconds of starting
- All recommended plugins installed without errors
- NodeJS 20.x tool configured in Manage Jenkins → Tools → NodeJS

---

## Experiment 4: Jenkins Pipeline Creation & GitHub Webhook

### Objective
Create a declarative Jenkins pipeline triggered automatically on every GitHub push.

### Steps Performed
1. Created a new Pipeline job named `devops-assignment-ci`
2. Configured the pipeline to use `Jenkinsfile` from SCM
3. Added GitHub webhook: `http://<jenkins-ip>:8080/github-webhook/`
4. Triggered first build manually — all stages passed
5. Pushed a test commit and confirmed the webhook triggered a new build automatically

### Pipeline Stages Output
| Stage | Status | Duration |
|-------|--------|----------|
| Checkout | ✅ Success | 8 s |
| Install Dependencies | ✅ Success | 34 s |
| Run Tests | ✅ Success | 12 s |
| Build | ✅ Success | 5 s |
| Deploy | ✅ Success | 11 s |

### Webhook Test Results
- Pushed commit `"fix: update health endpoint message"` to `main`
- GitHub webhook delivered payload within 2 seconds
- Jenkins build #3 triggered automatically — all stages green

### Observations
- Declarative `Jenkinsfile` provides clear, readable stage definitions
- `post { always { cleanWs() } }` prevents workspace disk bloat
- `when { branch 'main' }` correctly restricts Deploy stage to main branch only
- JUnit and Coverage Report HTML published after every build

---

## Screenshots
> Screenshots captured and stored in `screenshots/` folder.

- [x] Git repository on GitHub — showing all 4 lab folders
- [x] Jenkins dashboard with first successful build (#1)
- [x] Pipeline stage view (Blue Ocean) — all stages green
- [x] GitHub webhook configured and showing 200 response
- [x] JUnit test results published in Jenkins

---

## Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Jenkins blocked by firewall when GitHub delivered webhook | Opened port 8080: `sudo ufw allow 8080` |
| `npm ci` failed — `package-lock.json` not committed | Added `package-lock.json` to git and pushed |
| Deploy stage failed — no systemd service on fresh VM | Added `|| true`; created proper systemd service manually |

---

## Conclusion
Lab 1 established the foundational DevOps workflow. By combining **Git** for version control, **GitHub** as the remote repository, and **Jenkins** as the CI server, every code change now automatically triggers a pipeline that installs dependencies, runs tests, builds an artefact, and deploys to the target server.

The key insight is that CI removes the "it works on my machine" problem. Every commit is validated in a clean, reproducible environment. The declarative `Jenkinsfile` lives in the repository itself, making the pipeline version-controlled alongside the application code — a core DevOps principle.
