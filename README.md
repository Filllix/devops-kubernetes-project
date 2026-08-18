# DevOps Kubernetes Project

Project ini adalah latihan end-to-end untuk membangun aplikasi sederhana, menjalankannya di Kubernetes, lalu menambahkan observability dengan Prometheus. Cocok sebagai portfolio awal untuk belajar Cloud Engineer dan DevOps.

## Stack

- Node.js + Express
- Docker
- Kubernetes
- Helm
- Kind/local Kubernetes
- Prometheus
- Prometheus Operator/kube-prometheus-stack

## Fitur Kubernetes

- Namespace
- Deployment
- ReplicaSet
- Service
- ConfigMap
- Secret
- Health probe
- Resource request dan limit
- Ingress NGINX
- Metrics endpoint untuk Prometheus
- Prometheus scrape target

## Struktur Project

```text
app/                    Source code aplikasi Node.js
helm/devops-app/         Helm chart aplikasi
k8s/                    Manifest Kubernetes manual
kind/                   Konfigurasi Kind cluster
scripts/                Script deploy per environment
```

## Endpoint Aplikasi

| Endpoint | Fungsi |
| --- | --- |
| `/` | Halaman utama aplikasi |
| `/health` | Health check untuk liveness/readiness probe |
| `/info` | Informasi environment aplikasi |
| `/secret` | Validasi secret sudah terbaca |
| `/metrics` | Metrics Prometheus |

## Menjalankan Aplikasi Lokal

```powershell
cd app
npm install
npm start
```

Cek endpoint:

```powershell
curl http://localhost:3000/health
curl http://localhost:3000/metrics
```

## Deploy ke Kubernetes

Deploy namespace, config, secret, deployment, dan service:

```powershell
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

Cek status:

```powershell
kubectl get pods -n dev
kubectl get svc -n dev
kubectl describe svc devops-app -n dev
```
