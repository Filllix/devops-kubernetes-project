# DevOps Kubernetes Project

An end-to-end Kubernetes learning project focused on deploying, scaling, securing, monitoring, and operating a containerized application using production-oriented DevOps practices.

This project started as a simple Node.js application deployment and gradually evolved into a Kubernetes environment with Helm, autoscaling, network policies, persistent storage, Prometheus monitoring, Grafana dashboards, Alertmanager, and Discord notifications.

The main goal of this project is not only to deploy an application to Kubernetes, but also to understand how Kubernetes workloads behave under load, failure, scaling, and monitoring scenarios.

---

## Project Highlights

This project implements:

- Containerized Node.js application
- Kubernetes Deployment and Service
- ConfigMap and Secret management
- Resource Requests and Limits
- Liveness, Readiness, and Startup Probes
- Rolling Update and Rollback
- Horizontal Pod Autoscaler
- Metrics Server
- NGINX Ingress Controller
- NetworkPolicy
- ResourceQuota
- RBAC and ServiceAccount
- Persistent Volume and Persistent Volume Claim
- Helm Chart
- Prometheus monitoring
- ServiceMonitor
- Grafana dashboard
- Prometheus Alert Rules
- Alertmanager
- Discord alert notification
- Load testing for HPA validation
- Monitoring-as-Code using Grafana dashboard provisioning

---

# Architecture

```text
                        ┌───────────────────────┐
                        │       Developer       │
                        └───────────┬───────────┘
                                    │
                                    ▼
                             Docker Image
                                    │
                                    ▼
                        ┌───────────────────────┐
                        │  Kubernetes Cluster   │
                        │        (Kind)         │
                        └───────────┬───────────┘
                                    │
            ┌───────────────────────┼────────────────────────┐
            │                       │                        │
            ▼                       ▼                        ▼
       Deployment                Service                ConfigMap
            │                       │                        │
            │                       │                     Secret
            │                       │
            ▼                       ▼
          Pods                  NGINX Ingress
            │                       │
            │                       ▼
            │                    Browser
            │
            ├───────────────┐
            │               │
            ▼               ▼
      Metrics Server   ServiceMonitor
            │               │
            ▼               ▼
           HPA          Prometheus
            │               │
            │               ├───────────────┐
            │               │               │
            ▼               ▼               ▼
      Auto Scaling       Grafana      PrometheusRule
       2 → 10 Pods        Dashboard           │
                                             ▼
                                        Alertmanager
                                             │
                                             ▼
                                      Discord Alerts
```

---

# Technology Stack

| Category | Technology |
|---|---|
| Application | Node.js, Express |
| Containerization | Docker |
| Container Orchestration | Kubernetes |
| Local Kubernetes | Kind |
| Package Management | Helm |
| Ingress | NGINX Ingress Controller |
| Autoscaling | Horizontal Pod Autoscaler |
| Metrics | Metrics Server |
| Monitoring | Prometheus |
| Kubernetes Monitoring | kube-prometheus-stack |
| Dashboard | Grafana |
| Alerting | PrometheusRule, Alertmanager |
| Notifications | Discord Webhook |
| Networking Security | Kubernetes NetworkPolicy |
| Access Control | RBAC, ServiceAccount |
| Storage | PV, PVC |
| Load Testing | BusyBox load-generator |

---

# Repository Structure

```text
devops-kubernetes-project/
│
├── app/
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
│
├── helm/
│   └── devops-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── servicemonitor.yaml
│       │   ├── networkpolicy.yaml
│       │   ├── resourcequota.yaml
│       │   ├── serviceaccount.yaml
│       │   ├── role.yaml
│       │   └── rolebinding.yaml
│       │
│       ├── values.yaml
│       └── values-prod.yaml
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── networkpolicy.yaml
│   │
│   ├── networkpolicy/
│   │   ├── allowed-client.yaml
│   │   └── blocked-client.yaml
│   │
│   └── storage/
│       ├── pv.yaml
│       ├── pvc.yaml
│       └── storage-test-pod.yaml
│
├── monitoring/
│   ├── values.yaml
│   │
│   ├── prometheus/
│   │   ├── servicemonitor.yaml
│   │   └── devops-app-alerts.yaml
│   │
│   ├── alertmanager/
│   │   └── discord-alertmanager-config.yaml
│   │
│   └── grafana/
│       └── dashboard/
│           ├── devops-app-dashboard.json
│           └── devops-app-dashboard-configmap.yaml
│
├── load-generator.yaml
└── README.md
```

---

# Application Endpoints

| Endpoint | Description |
|---|---|
| `/` | Main application page |
| `/health` | Application health endpoint |
| `/info` | Environment and application information |
| `/secret` | Verify Kubernetes Secret injection |
| `/metrics` | Prometheus application metrics |

Example:

```powershell
curl http://localhost:3000/health
```

Prometheus metrics:

```powershell
curl http://localhost:3000/metrics
```

---

# Running the Application Locally

```powershell
cd app
npm install
npm start
```

Application:

```text
http://localhost:3000
```

---

# Kubernetes Deployment

Create or deploy Kubernetes resources:

```powershell
kubectl apply -f k8s/
```

Check Pods:

```powershell
kubectl get pods -n dev
```

Check Services:

```powershell
kubectl get svc -n dev
```

Check Deployment:

```powershell
kubectl get deployment -n dev
```

---

# Helm Deployment

The application is also packaged using Helm.

Example deployment:

```powershell
helm upgrade --install devops-app .\helm\devops-app `
  -n dev `
  --create-namespace `
  -f .\helm\devops-app\values.yaml
```

Production values:

```powershell
helm upgrade --install devops-app .\helm\devops-app `
  -n dev `
  -f .\helm\devops-app\values.yaml `
  -f .\helm\devops-app\values-prod.yaml
```

Validate the Helm Chart:

```powershell
helm lint .\helm\devops-app
```

Render the manifests before deployment:

```powershell
helm template devops-app .\helm\devops-app -n dev
```

---

# Kubernetes Health Probes

The application uses Kubernetes health probes to improve workload reliability.

Implemented probes:

- Liveness Probe
- Readiness Probe
- Startup Probe

These probes allow Kubernetes to detect unhealthy application instances and restart or temporarily remove them from Service traffic when necessary.

---

# Resource Management

CPU and memory requests/limits are configured for the application.

Example:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 64Mi
```

Resource Requests are especially important because the Horizontal Pod Autoscaler calculates CPU utilization relative to the configured CPU request.

---

# Horizontal Pod Autoscaler

The application uses Kubernetes HPA based on CPU utilization.

Configuration:

```text
Minimum Replicas : 2
Maximum Replicas : 10
CPU Target       : 50%
```

Check HPA:

```powershell
kubectl get hpa -n dev
```

Live monitoring:

```powershell
kubectl get hpa -n dev -w
```

---

# HPA Load Test

A dedicated load-generator Deployment is included to validate autoscaling behavior.

Start the load generator:

```powershell
kubectl scale deployment load-generator -n dev --replicas=3
```

Monitor application CPU:

```powershell
kubectl top pods -n dev
```

Monitor autoscaling:

```powershell
kubectl get hpa -n dev -w
```

During testing, the application successfully scaled from:

```text
2 Pods
  ↓
3 Pods
  ↓
6 Pods
  ↓
10 Pods
```

Observed CPU behavior:

```text
6%
↓
64%
↓
144%
↓
115%
↓
85%
↓
~50%
```

As additional replicas became available, the workload was distributed across the new Pods and CPU utilization moved toward the HPA target.

Stop the load generator:

```powershell
kubectl scale deployment load-generator -n dev --replicas=0
```

The HPA then automatically performs scale-down after its stabilization period.

---

# NetworkPolicy

Network policies are implemented to restrict traffic between workloads.

The project includes examples for:

- Allowed client
- Blocked client
- Application-specific ingress rules

Example:

```powershell
kubectl get networkpolicy -n dev
```

Inspect policy:

```powershell
kubectl describe networkpolicy -n dev
```

This was used to understand Kubernetes network isolation and workload-level access control.

---

# Persistent Storage

The project includes Kubernetes persistent storage resources:

- PersistentVolume
- PersistentVolumeClaim
- Storage test Pod

Example:

```powershell
kubectl get pv
kubectl get pvc -n dev
```

---

# RBAC

The Helm Chart includes:

- ServiceAccount
- Role
- RoleBinding

This separates application permissions from the default Kubernetes ServiceAccount and provides a foundation for least-privilege access.

---

# Monitoring Architecture

The monitoring stack uses `kube-prometheus-stack`.

```text
Application
    │
    │ /metrics
    ▼
Service
    │
    ▼
ServiceMonitor
    │
    ▼
Prometheus
    │
    ├──────────────► Grafana
    │
    ▼
PrometheusRule
    │
    ▼
Alertmanager
    │
    ▼
Discord
```

---

# Prometheus

The application exposes:

```text
/metrics
```

Prometheus discovers the application through a Kubernetes `ServiceMonitor`.

Check ServiceMonitor:

```powershell
kubectl get servicemonitor -A
```

Check Prometheus:

```powershell
kubectl get prometheus -n monitoring
```

Port-forward Prometheus:

```powershell
kubectl port-forward `
  svc/monitoring-kube-prometheus-prometheus `
  -n monitoring `
  9090:9090
```

Open:

```text
http://localhost:9090
```

---

# Grafana Dashboard

Grafana is used to visualize both application and Kubernetes metrics.

Dashboard panels include:

- Application Availability
- Healthy Targets
- Available Replicas
- Desired Replicas
- CPU Utilization
- Memory Usage
- Application Replica Count
- Pod Restart Count
- Pod Status
- HPA Current Replicas
- HPA Desired Replicas

Port-forward Grafana:

```powershell
kubectl port-forward `
  svc/monitoring-grafana `
  -n monitoring `
  3000:80
```

Open:

```text
http://localhost:3000
```

---

# Grafana Dashboard as Code

The Grafana dashboard is exported and stored inside the repository:

```text
monitoring/grafana/dashboard/devops-app-dashboard.json
```

A Kubernetes ConfigMap is used to provision the dashboard:

```text
monitoring/grafana/dashboard/devops-app-dashboard-configmap.yaml
```

The ConfigMap contains:

```yaml
metadata:
  labels:
    grafana_dashboard: "1"
```

The Grafana sidecar automatically discovers ConfigMaps with this label and loads the dashboard.

Architecture:

```text
Git Repository
      │
      ▼
Dashboard JSON
      │
      ▼
Kubernetes ConfigMap
      │
      ▼
Grafana Dashboard Sidecar
      │
      ▼
Grafana Dashboard
```

This approach allows the dashboard to be version-controlled and restored automatically.

---

# Custom Prometheus Alerts

Three application-level alerts were implemented.

## High CPU

```text
DevOpsAppHighCPU
```

Triggers when application CPU exceeds the configured threshold for more than two minutes.

Final threshold:

```text
CPU > 80%
```

---

## Pod Restart

```text
DevOpsAppPodRestarting
```

Detects container restarts during a recent monitoring window.

This alert was validated by intentionally restarting the application container.

---

## Application Target Down

```text
DevOpsAppTargetDown
```

Detects both:

- Prometheus scrape failure
- Complete disappearance of the application target

The rule uses both:

```promql
up{namespace="dev",job="devops-app"} == 0
```

and:

```promql
absent(up{namespace="dev",job="devops-app"})
```

This prevents missing alerts when the Service has no EndpointSlice targets.

---

# Alert Lifecycle Testing

The custom alerts were tested end-to-end.

```text
Normal
  ↓
Condition detected
  ↓
PENDING
  ↓
FIRING
  ↓
Alertmanager
  ↓
Discord Notification
  ↓
Issue resolved
  ↓
RESOLVED
```

Validated alerts:

| Alert | Prometheus | Alertmanager | Discord |
|---|---|---|---|
| High CPU | ✅ | ✅ | ✅ |
| Pod Restart | ✅ | ✅ | ✅ |
| Target Down | ✅ | ✅ | ✅ |

---

# Alertmanager

Alertmanager receives alerts generated by Prometheus.

Port-forward:

```powershell
kubectl port-forward `
  svc/monitoring-kube-prometheus-alertmanager `
  -n monitoring `
  9093:9093
```

Open:

```text
http://localhost:9093
```

---

# Discord Notification

Application alerts are routed from Alertmanager to Discord.

```text
Prometheus
    ↓
PrometheusRule
    ↓
Alertmanager
    ↓
AlertmanagerConfig
    ↓
Discord Webhook
    ↓
#devops-alerts
```

The webhook URL is **not stored directly in Git**.

Instead, it is stored as a Kubernetes Secret:

```text
discord-webhook
```

The Alertmanager configuration only references:

```yaml
apiURL:
  name: discord-webhook
  key: url
```

This prevents sensitive webhook credentials from being committed to the repository.

---

# Example Monitoring Scenario

One complete test scenario implemented in this project:

```text
Load Generator
      ↓
HTTP Request Load
      ↓
Application CPU increases
      ↓
HPA detects CPU > 50%
      ↓
Application scales from 2 → 10 Pods
      ↓
Prometheus collects application metrics
      ↓
Grafana visualizes CPU and replica changes
      ↓
PrometheusRule evaluates alert condition
      ↓
Alertmanager receives FIRING alert
      ↓
Discord receives notification
```

When the load is stopped:

```text
Load Generator → 0 replicas
        ↓
CPU decreases
        ↓
Alert resolves
        ↓
Discord receives RESOLVED notification
        ↓
HPA eventually scales back toward 2 replicas
```

---

# Troubleshooting Experience

This project also included hands-on troubleshooting for several Kubernetes scenarios:

- `ImagePullBackOff`
- `CrashLoopBackOff`
- Pending Pods
- ResourceQuota issues
- Helm configuration conflicts
- ServiceMonitor discovery issues
- Prometheus target discovery
- Prometheus Operator RBAC
- Prometheus configuration reload
- Alert rule validation
- Alertmanager routing
- Discord webhook configuration
- Service selector and EndpointSlice behavior
- HPA scale-up and scale-down behavior
- Windows PowerShell quoting and YAML/JSON handling

Troubleshooting these problems was an important part of understanding how Kubernetes and Prometheus Operator work internally.

---

# Useful Commands

## Kubernetes

```powershell
kubectl get pods -A
kubectl get svc -A
kubectl get deployment -A
kubectl get hpa -A
kubectl top pods -n dev
```

## Monitoring

```powershell
kubectl get prometheus -n monitoring
kubectl get servicemonitor -A
kubectl get prometheusrule -A
kubectl get alertmanager -n monitoring
kubectl get alertmanagerconfig -A
```

## Helm

```powershell
helm list -A
helm lint .\helm\devops-app
helm template devops-app .\helm\devops-app
```

---

# Security Considerations

Sensitive information must never be committed to this repository.

Do not commit:

- Discord Webhook URLs
- Kubernetes Secret values
- Tokens
- Passwords
- Cloud credentials
- kubeconfig files

Secrets should be created directly inside Kubernetes or injected through a secure secret-management mechanism.

---

# Key Learning Outcomes

Through this project I gained practical experience with:

- Kubernetes workload lifecycle management
- Docker container deployment
- Kubernetes Services and networking
- Health checks and self-healing
- Resource management
- Horizontal autoscaling
- Kubernetes RBAC
- Network isolation
- Persistent storage
- Helm templating
- Prometheus metrics
- Kubernetes ServiceMonitor
- PromQL
- Grafana dashboards
- Prometheus alert rules
- Alertmanager routing
- Discord notification integration
- Failure simulation
- Load testing
- Observability
- Troubleshooting Kubernetes environments

---

# Project Status

### Kubernetes Core

- [x] Kubernetes cluster
- [x] Application Deployment
- [x] Service
- [x] ConfigMap
- [x] Secret
- [x] Health probes
- [x] Resource Requests and Limits
- [x] Rolling Update and Rollback
- [x] HPA
- [x] Metrics Server
- [x] NGINX Ingress
- [x] NetworkPolicy
- [x] ResourceQuota
- [x] RBAC
- [x] Persistent Storage
- [x] Helm Chart

### Observability

- [x] Prometheus
- [x] ServiceMonitor
- [x] Application Metrics
- [x] Grafana
- [x] Custom Grafana Dashboard
- [x] Dashboard provisioning
- [x] PrometheusRule
- [x] Alertmanager
- [x] High CPU Alert
- [x] Pod Restart Alert
- [x] Target Down Alert
- [x] Discord Notification
- [x] Alert recovery testing

---

# Future Improvements

The next stages of this project may include:

- GitOps with Argo CD
- CI/CD Pipeline
- Jenkins integration
- Advanced Grafana dashboards
- Loki for centralized logging
- Distributed tracing
- AWS Kubernetes deployment
- Terraform infrastructure provisioning
- Ansible configuration management
- TLS and HTTPS
- External Secrets
- Production-grade ingress
- Persistent Prometheus storage
- SLO / SLI monitoring
- GitHub Actions
- Security scanning
- Kubernetes policy enforcement

---

# Author

**Aldo**

Aspiring DevOps Engineer focused on:

- Kubernetes
- AWS
- Infrastructure Automation
- CI/CD
- Observability
- Infrastructure as Code

---

## Summary

This project demonstrates an end-to-end Kubernetes DevOps workflow covering:

**Deployment → Security → Scaling → Monitoring → Alerting → Notification**

rather than only deploying an application into a Kubernetes cluster.