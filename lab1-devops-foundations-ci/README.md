# Lab 1: DevOps Foundations & Continuous Integration

## Objective
Build a foundational DevOps workflow with version control, continuous integration, and automated deployment using Git, GitHub, Jenkins, and Ubuntu 24.04 LTS.

## Tools & Environment
| Tool | Version | Purpose |
|------|---------|---------|
| Ubuntu | 24.04 LTS | Base OS |
| Git | 2.x | Version control |
| GitHub | - | Remote repository |
| Jenkins | LTS | CI/CD automation |
| Node.js | 20.x | Runtime for sample app |
| Visual Studio Code | Latest | IDE |

## Folder Structure
```
lab1-devops-foundations-ci/
+-- configs/
¦   +-- Jenkinsfile          # Declarative Jenkins pipeline
¦   +-- .gitignore           # Git ignore rules
+-- scripts/
¦   +-- setup.sh             # Tool installation script
¦   +-- build.sh             # Application build script
¦   +-- test.sh              # Test runner script
+-- screenshots/             # Evidence screenshots (add here)
+-- reports/
    +-- lab1-report.md       # Detailed lab report
```

## Experiments Covered
1. Install and configure Git, Node.js, and Jenkins on Ubuntu 24.04
2. Create a GitHub repository and push the sample application
3. Configure Jenkins with GitHub webhook integration
4. Write a declarative Jenkinsfile with Build ? Test ? Deploy stages
5. Trigger automated pipeline on each commit
6. Maintain clean commit history with conventional commits

## Commands Log
```bash
# Install Git
sudo apt update && sudo apt install -y git

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Initialize repository
git init && git add . && git commit -m "feat: initial project setup"

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update && sudo apt install -y jenkins
sudo systemctl start jenkins && sudo systemctl enable jenkins
```

## Pipeline Stages
1. **Checkout** – Clone repository from GitHub
2. **Install** – `npm install`
3. **Test** – `npm test`
4. **Build** – Prepare build artifacts
5. **Deploy** – Deploy to target environment

## Evidence
- Screenshots in `screenshots/` folder
- Jenkins build logs captured in `reports/`
