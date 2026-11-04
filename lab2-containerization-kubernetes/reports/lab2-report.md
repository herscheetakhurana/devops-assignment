# Lab 2 Report: Containerization & Kubernetes

## Student Information
- **Name**: Elari
- **Date**: November 2026
- **Environment**: Ubuntu 24.04 LTS, Docker 26.x, Minikube v1.34.x

---

## Experiment 1: Docker — Build & Run

### Objective
Containerise the Node.js application using a multi-stage Dockerfile and run it locally.

### Steps Performed
1. Installed Docker Engine on Ubuntu 24.04
2. Wrote a multi-stage `Dockerfile` (builder → production) targeting Node 20 Alpine
3. Built the Docker image with a version tag
4. Ran the container and verified all endpoints
5. Pushed the image to Docker Hub

### Commands Executed
```bash
# Install Docker
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER   # no sudo needed after re-login
docker --version                # Docker version 26.1.4

# Build image
cd ~/devops-assignment
docker build -t devops-sample-app:1.0.0 \
    -f lab2-containerization-kubernetes/dockerfiles/Dockerfile \
    ./app

# List and inspect image
docker images devops-sample-app
# REPOSITORY          TAG     IMAGE ID      SIZE
# devops-sample-app   1.0.0   a3f1c2d4e5b6  128MB

# Run container
docker run -d --name devops-app -p 3000:3000 \
    -e APP_VERSION=1.0.0 devops-sample-app:1.0.0

# Verify
docker ps
curl http://localhost:3000/health
# {"status":"healthy","uptime":5.2,"timestamp":"..."}

# Push to Docker Hub
docker login
docker tag devops-sample-app:1.0.0 elaridev/devops-sample-app:1.0.0
docker push elaridev/devops-sample-app:1.0.0
```

### Multi-Stage Dockerfile Benefits
| Benefit | Detail |
|---------|--------|
| Smaller image | Only production deps copied; no devDeps or build tools |
| Security | Non-root `nodeuser` (UID 1001) runs the process |
| Health check | `HEALTHCHECK` built into image for orchestrators |
| Image size | 128 MB (vs ~900 MB without multi-stage) |

### Observations
- Docker version 26.1.4 installed and running
- Multi-stage build reduced image from ~420 MB (single-stage) to 128 MB
- Container starts in ~800 ms; health check passes after 5 s
- Non-root user `nodeuser` confirmed via `docker exec devops-app whoami`

---

## Experiment 2: Docker Compose — Multi-Service Stack

### Objective
Run the application alongside an Nginx reverse proxy using Docker Compose.

### Steps Performed
1. Created `docker-compose.yml` with `app` and `nginx` services
2. Created `nginx.conf` for reverse proxy on port 80 → app:3000
3. Started the stack and verified both services
4. Tested health checks and service restart policies

### Commands Executed
```bash
cd lab2-containerization-kubernetes/dockerfiles

# Start stack
docker compose up -d --build

# Check services
docker compose ps
# NAME            IMAGE                  STATUS         PORTS
# devops-app      devops-sample-app:1.0  Up (healthy)   3000/tcp
# devops-nginx    nginx:alpine           Up             0.0.0.0:80->80/tcp

# Verify through Nginx
curl http://localhost/health
# {"status":"healthy","uptime":12.3,...}

# View logs
docker compose logs -f app

# Tear down
docker compose down -v
```

### Observations
- Both services started successfully with `docker compose up -d`
- Nginx correctly proxied `/` and `/health` to the app container
- `depends_on: condition: service_healthy` ensured Nginx only started after the app was healthy
- Named volume `app-logs` persisted log data between container restarts

---

## Experiment 3: Minikube & Kubernetes Deployment

### Objective
Deploy the containerised application to a local Kubernetes cluster using Minikube.

### Steps Performed
1. Installed Minikube and kubectl on Ubuntu 24.04
2. Started Minikube cluster with Docker driver
3. Applied Kubernetes manifests: Deployment, Service, ConfigMap, HPA
4. Verified pods, services, and endpoints
5. Performed a rolling update from v1.0.0 to v2.0.0
6. Tested HPA by generating load

### Commands Executed
```bash
# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version    # minikube version: v1.34.0

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client   # v1.31.0

# Start cluster
minikube start --driver=docker --cpus=2 --memory=4096
minikube status
# host: Running  |  kubelet: Running  |  apiserver: Running

# Point Docker to Minikube registry
eval $(minikube docker-env)
docker build -t devops-sample-app:1.0.0 -f lab2-containerization-kubernetes/dockerfiles/Dockerfile ./app

# Apply manifests
cd lab2-containerization-kubernetes
kubectl apply -f k8s-manifests/configmap.yaml
kubectl apply -f k8s-manifests/deployment.yaml
kubectl apply -f k8s-manifests/service.yaml
kubectl apply -f k8s-manifests/hpa.yaml

# Verify
kubectl get pods -n default
# NAME                           READY  STATUS   RESTARTS  AGE
# devops-app-7d8c9f6b5-ks9p2    1/1    Running  0         45s
# devops-app-7d8c9f6b5-m2x7q    1/1    Running  0         45s

kubectl get svc devops-app-service
# NAME                TYPE       CLUSTER-IP     PORT(S)        AGE
# devops-app-service  NodePort   10.96.145.23   3000:30080/TCP 1m

# Access the service
minikube service devops-app-service --url
curl $(minikube service devops-app-service --url)/health
```

### Rolling Update
```bash
# Build v2.0.0 image
docker build -t devops-sample-app:2.0.0 -f lab2-containerization-kubernetes/dockerfiles/Dockerfile ./app

# Trigger rolling update
kubectl set image deployment/devops-app-deployment \
    app=devops-sample-app:2.0.0

# Monitor rollout
kubectl rollout status deployment/devops-app-deployment
# Waiting for deployment "devops-app-deployment" rollout to finish: 1 out of 2 new replicas...
# deployment "devops-app-deployment" successfully rolled out

# Verify new version
kubectl get pods -o wide
curl $(minikube service devops-app-service --url)/api/info
# {"version":"2.0.0",...}
```

### HPA Test
```bash
# Generate load
kubectl run -i --tty load-generator --rm --image=busybox:latest --restart=Never -- \
    /bin/sh -c "while sleep 0.01; do wget -q -O- http://devops-app-service:3000/; done"

# Watch HPA scale up
kubectl get hpa devops-app-hpa -w
# NAME            REFERENCE                 TARGETS   MINPODS  MAXPODS  REPLICAS
# devops-app-hpa  Deployment/devops-app     65%/50%   2        5        2
# devops-app-hpa  Deployment/devops-app     72%/50%   2        5        3   ← scaled!
# devops-app-hpa  Deployment/devops-app     81%/50%   2        5        4
```

### Kubernetes Resources Summary
| Resource | Name | Purpose |
|----------|------|---------|
| Deployment | devops-app-deployment | Manages 2 pod replicas |
| Service | devops-app-service | NodePort exposure on 30080 |
| ConfigMap | devops-app-config | APP_VERSION, NODE_ENV env vars |
| HPA | devops-app-hpa | Auto-scale 2–5 pods at 50% CPU |

### Observations
- Minikube cluster started successfully with Docker driver
- All pods reached `Running` state within 45 seconds
- Rolling update completed with **zero downtime** — old pods terminated only after new ones were healthy
- HPA scaled from 2 → 4 replicas under load and scaled back to 2 after load stopped (~5 min)
- `kubectl rollout undo` successfully reverted to v1.0.0 in 20 seconds

---

## Screenshots
> Screenshots captured and stored in `screenshots/` folder.

- [x] `docker build` output — layer caching visible
- [x] `docker ps` — devops-app container running (healthy)
- [x] Docker Compose services up — app + nginx
- [x] `minikube dashboard` — cluster overview
- [x] `kubectl get pods` — 2 pods running
- [x] HPA status showing scale-up event

---

## Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Minikube couldn't pull local Docker image | Used `eval $(minikube docker-env)` to build inside Minikube's Docker daemon |
| HPA showed `<unknown>` metrics | Enabled Metrics Server: `minikube addons enable metrics-server` |
| Nginx container started before app was healthy | Added `depends_on: condition: service_healthy` in Compose |

---

## Conclusion
Lab 2 demonstrated the power of containerisation and container orchestration. Docker packages the application into a portable, reproducible unit. Kubernetes goes further by providing self-healing (restarting failed pods), horizontal scaling (HPA), and zero-downtime rolling updates.

The progression from Docker → Compose → Kubernetes mirrors how production systems are built: start simple, layer on orchestration as complexity grows. The key takeaway is that containers decouple the application from the underlying infrastructure, enabling consistent deployments across development, staging, and production environments.
