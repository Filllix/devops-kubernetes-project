# DevOps Kubernetes Project

An end-to-end DevOps and Kubernetes engineering project focused on building, securing, observing, automating, and deploying a containerized application from a local Kubernetes environment to AWS EKS.

This project started as a Kubernetes learning lab using Kind and gradually evolved into a production-oriented DevOps platform implementing:

- Kubernetes workload management
- Helm packaging
- Horizontal Pod Autoscaling
- CI/CD and DevSecOps
- Jenkins on Kubernetes
- GitOps with Argo CD
- Prometheus and Grafana observability
- Centralized logging with Loki and Grafana Alloy
- SLO and Error Budget monitoring
- Terraform Infrastructure as Code
- AWS EKS
- AWS Application Load Balancer
- Terraform remote state using Amazon S3

The primary goal of this project is not only to deploy an application, but to understand how a modern DevOps platform behaves under deployment, scaling, failure, security scanning, monitoring, GitOps reconciliation, and cloud infrastructure scenarios.

---

# Project Status

| Phase | Status |
|---|---|
| Kubernetes Fundamentals | ✅ Completed |
| Helm & Kubernetes Security | ✅ Completed |
| Monitoring & Alerting | ✅ Completed |
| CI/CD & DevSecOps | ✅ Completed |
| GitOps / Argo CD | ✅ Completed |
| Centralized Logging | ✅ Completed |
| Advanced Observability / SLO | ✅ Completed |
| Jenkins CI/CD | ✅ Completed |
| Terraform + AWS EKS | ✅ Completed |
| Ansible | ⬜ Next |
| Production Hardening | ⬜ Planned |
| Final Portfolio Documentation | 🟡 In Progress |

---

# Architecture

## Current AWS Architecture

```text
                         Developer
                             │
                             ▼
                           GitHub
                             │
                 ┌───────────┴───────────┐
                 │                       │
                 ▼                       ▼
              Jenkins                 Argo CD
                 │                       │
                 ▼                       │
        Kubernetes Build Agent           │
                 │                       │
        ┌────────┼─────────┐             │
        │        │         │             │
        ▼        ▼         ▼             │
      Node      Helm     Kaniko           │
                         │                │
                         ▼                │
                    Docker Hub            │
                         │                │
                         ▼                │
                       Trivy              │
                         │                │
                         ▼                │
                 GitOps Image Update ─────┘
                                          │
                                          ▼
                                    Amazon EKS
                                          │
                         ┌────────────────┼────────────────┐
                         │                │                │
                         ▼                ▼                ▼
                    Deployment         Service         HPA
                         │                │
                         ▼                ▼
                       Pods       ServiceMonitor
                         │                │
                         │                ▼
                         │            Prometheus
                         │                │
                         │          ┌─────┴─────┐
                         │          ▼           ▼
                         │       Grafana   Alertmanager
                         │
                         ▼
              AWS Load Balancer Controller
                         │
                         ▼
                 Application Load Balancer
                         │
                         ▼
                      Internet
Infrastructure Architecture

AWS infrastructure is provisioned using Terraform.

Terraform
   │
   ├── VPC
   │    ├── Public Subnet A
   │    ├── Public Subnet B
   │    ├── Private Subnet A
   │    └── Private Subnet B
   │
   ├── Internet Gateway
   ├── Route Tables
   │
   ├── IAM
   │    ├── EKS Cluster Role
   │    ├── EKS Node Role
   │    ├── OIDC Provider
   │    └── AWS Load Balancer Controller Role
   │
   ├── Amazon EKS
   │    └── Managed Node Group
   │
   └── Amazon S3
        └── Terraform Remote State

Terraform state is stored remotely in Amazon S3 with:

Server-side encryption
S3 versioning
Public access blocking
State locking
Environment-specific state path
s3://<terraform-state-bucket>/eks/dev/terraform.tfstate
Technology Stack
Category	Technology
Application	Node.js, Express
Containerization	Docker
Container Registry	Docker Hub
Kubernetes	Kubernetes, Kind, Amazon EKS
Package Management	Helm
Infrastructure as Code	Terraform
Cloud Platform	AWS
Cloud Kubernetes	Amazon EKS
Cloud Networking	VPC, Subnet, Internet Gateway, Route Table
Cloud Load Balancing	AWS Application Load Balancer
Ingress	AWS Load Balancer Controller
CI/CD	GitHub Actions, Jenkins
Container Build	Docker Buildx, Kaniko
Security Scanning	Trivy
GitOps	Argo CD
Metrics	Prometheus
Dashboard	Grafana
Logging	Loki, Grafana Alloy
Alerting	PrometheusRule, Alertmanager
Notifications	Discord Webhook
Autoscaling	Horizontal Pod Autoscaler
Security	RBAC, NetworkPolicy, ServiceAccount, IRSA
Terraform State	Amazon S3
Load Testing	BusyBox Load Generator
Repository Structure
devops-kubernetes-project/
│
├── app/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
│
├── helm/
│   └── devops-app/
│       ├── templates/
│       ├── values.yaml
│       └── values-prod.yaml
│
├── terraform/
│   ├── backend.tf
│   ├── backend-resources.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── iam.tf
│   ├── eks.tf
│   ├── alb-controller.tf
│   └── alb-controller-iam-policy.json
│
├── argocd/
│   └── devops-app-eks.yaml
│
├── monitoring/
│   ├── prometheus/
│   ├── prometheus-rules/
│   ├── alertmanager/
│   └── grafana/
│
├── logging/
│
├── jenkins/
│   ├── jenkins.yaml
│   └── jenkins-rbac.yaml
│
├── k8s/
│
├── .github/
│   └── workflows/
│
├── Jenkinsfile
├── load-generator.yaml
└── README.md
Application

The application is a Node.js / Express service exposing several endpoints.

Endpoint	Description
/	Main application
/health	Health check
/info	Application information
/secret	Secret injection verification
/metrics	Prometheus metrics
/error	Intentional HTTP 500 endpoint for SLO testing

The application also exposes custom Prometheus metrics:

http_requests_total
http_request_duration_seconds

These metrics are used for availability, latency, error-rate, and SLO calculations.

Kubernetes Features

The project implements:

Namespace isolation
Deployment
ReplicaSet
Service
ConfigMap
Secret
Resource Requests and Limits
Liveness Probe
Readiness Probe
Startup Probe
Rolling Update
Rollback
Horizontal Pod Autoscaler
Metrics Server
NetworkPolicy
ResourceQuota
RBAC
ServiceAccount
Persistent Volume
Persistent Volume Claim
Helm
Ingress
ServiceMonitor
Horizontal Pod Autoscaler

The application uses CPU-based Horizontal Pod Autoscaling.

Minimum Replicas : 2
Maximum Replicas : 10
CPU Target       : 50%

Load testing successfully demonstrated automatic scale-out from a small number of replicas up to the configured maximum.

The project also solves a common GitOps issue where Argo CD and HPA compete over the Deployment replica count.

Argo CD is configured to ignore:

/spec/replicas

for the application Deployment while still managing the remaining Deployment configuration.

Helm

The application is packaged using a reusable Helm Chart.

Validation:

helm lint helm/devops-app

Manifest rendering:

helm template devops-app helm/devops-app

Deployment:

helm upgrade --install devops-app `
  helm/devops-app `
  -n dev

The Helm chart manages:

Deployment
Service
Ingress
HPA
ConfigMap
Secret
ServiceAccount
RBAC
NetworkPolicy
ResourceQuota
ServiceMonitor

For AWS EKS, the chart also manages the ALB Ingress configuration.

CI/CD — GitHub Actions

GitHub Actions provides the first CI/CD implementation.

Pipeline:

Git Push
   ↓
npm ci
   ↓
Node.js Validation
   ↓
Helm Lint
   ↓
Helm Template
   ↓
Docker Build
   ↓
Trivy Scan
   ↓
Docker Hub
   ↓
Update Helm Image Tag
   ↓
Git Commit
   ↓
Argo CD

The container image uses immutable Git SHA tags for deployment.

DevSecOps

Trivy is used as a security gate for container images.

The pipeline scans:

HIGH
CRITICAL

vulnerabilities.

A pipeline fails when unacceptable vulnerabilities are detected.

During development, a real OpenSSL vulnerability in the Alpine base image was detected and fixed by upgrading packages during the runtime image build.

Jenkins CI/CD

A second CI/CD implementation was built using Jenkins running inside Kubernetes.

Jenkins uses dynamic Kubernetes agents rather than executing build workloads directly on the controller.

Pipeline architecture:

Jenkins Controller
       │
       ▼
Kubernetes Agent Pod
       │
 ┌─────┼──────┬─────────┐
 ▼     ▼      ▼         ▼
Node   Helm   Kaniko   Trivy

The Jenkins pipeline performs:

Git checkout
Git SHA generation
npm ci
Node.js validation
Helm lint
Helm template
Kaniko image build
Docker Hub push
Trivy security scan
GitOps Helm image update
Git push
Argo CD deployment

Final workflow:

GitHub
  ↓
Jenkins
  ↓
Kaniko
  ↓
Docker Hub
  ↓
Trivy
  ↓
Update values.yaml
  ↓
GitHub
  ↓
Argo CD
  ↓
Kubernetes
GitOps with Argo CD

Argo CD manages application deployment from Git.

Git Repository
      ↓
Argo CD
      ↓
Helm Chart
      ↓
Kubernetes

Configuration:

Repository : Filllix/devops-kubernetes-project
Branch     : main
Path       : helm/devops-app
Namespace  : dev

Features:

Automated synchronization
Self healing
Automatic pruning
HPA replica ignore configuration
Git SHA image deployment

Argo CD was first validated on the local Kind cluster and later deployed directly into Amazon EKS.

Self-Healing Validation

Argo CD self-healing was tested by manually changing live Kubernetes configuration.

Example:

Git desired state:
imagePullPolicy: IfNotPresent

Manual cluster modification:
imagePullPolicy: Always

Argo CD:
detect drift
↓
self heal
↓
IfNotPresent restored
Monitoring

The monitoring stack uses:

kube-prometheus-stack

Architecture:

Application
    │
    │ /metrics
    ▼
Service
    ▼
ServiceMonitor
    ▼
Prometheus
    │
    ├──────────► Grafana
    │
    ▼
PrometheusRule
    ▼
Alertmanager
    ▼
Discord

Prometheus successfully scrapes application metrics both in the local Kubernetes environment and on Amazon EKS.

Grafana

Grafana dashboards visualize:

Application availability
CPU utilization
Memory usage
Replica count
Pod restart count
HPA current replicas
HPA desired replicas
HTTP request rate
HTTP errors
Application latency
SLO availability
Error budget
Error budget burn rate

Dashboards are stored as code and provisioned using ConfigMaps.

Alerting

Prometheus alert rules include:

DevOpsAppHighCPU
DevOpsAppPodRestarting
DevOpsAppTargetDown

Alerts are routed:

Prometheus
   ↓
Alertmanager
   ↓
AlertmanagerConfig
   ↓
Discord Webhook

Both FIRING and RESOLVED notifications were successfully validated.

Centralized Logging

Centralized logging uses:

Pod stdout/stderr
      ↓
Grafana Alloy
      ↓
Loki
      ↓
Grafana

The application emits structured JSON logs containing:

timestamp
method
path
status
duration_ms

Example LogQL:

{namespace="dev", pod=~"devops-app-.*"} | json

Logging dashboards include:

Application Log Volume
HTTP Request Rate
Log Volume by Pod
Application Logs
HTTP Errors
Slow Requests
SLO and Error Budget

The project implements production-style Service Level Objectives.

Availability target:

99.9%

Allowed error budget:

0.1%

Latency objective:

p95 < 250 ms

A second latency SLO measures the percentage of requests completing below 500 ms.

Implemented recording rules:

devops_app:http_error_rate:5m
devops_app:availability:5m
devops_app:latency_p95_seconds:5m
devops_app:latency_slo_ratio:5m
Error Budget Burn Rate

Burn rate is calculated using:

devops_app:http_error_rate:5m / 0.001

Interpretation:

0x      No error budget consumption
1x      Consuming at allowed SLO rate
>6x     Warning
>14.4x  Critical

Alerts:

DevOpsAppWarningErrorBudgetBurn
DevOpsAppHighErrorBudgetBurn

An intentional /error endpoint was used to generate HTTP 500 responses and validate the complete alert lifecycle.

Terraform Infrastructure as Code

AWS infrastructure is managed through Terraform.

Resources include:

VPC
Public Subnets
Private Subnets
Internet Gateway
Route Tables
IAM Roles
IAM Policies
EKS Control Plane
Managed Node Group
EKS Access Entries
OIDC Provider
AWS Load Balancer Controller IAM Role
S3 Terraform State Backend

Typical workflow:

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

Terraform was also tested using:

terraform destroy

followed by:

terraform apply

to verify that the infrastructure could be reproducibly recreated from code.

Amazon EKS

The application has successfully migrated from a local Kind cluster to Amazon EKS.

Implemented components:

EKS Control Plane
Managed Node Group
Kubernetes access using EKS Access Entries
Helm application deployment
Prometheus monitoring
Argo CD
AWS Load Balancer Controller
Application Load Balancer

Worker nodes were scaled when the cluster reached pod scheduling limits while deploying the full monitoring and GitOps stack.

This provided hands-on experience with Kubernetes capacity planning.

AWS Load Balancer Controller

AWS Load Balancer Controller is integrated with EKS using:

EKS OIDC Provider
      ↓
IAM Role
      ↓
IRSA
      ↓
Kubernetes ServiceAccount
      ↓
AWS Load Balancer Controller

The application Ingress uses:

alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/healthcheck-path: /health

The controller automatically provisions an AWS Application Load Balancer.

Final traffic flow:

Internet
   ↓
AWS Application Load Balancer
   ↓
Kubernetes Ingress
   ↓
Service
   ↓
Application Pod

The application was successfully accessed publicly through the ALB DNS endpoint.

Terraform Remote State

Terraform state is stored remotely using Amazon S3.

Developer
    ↓
Terraform
    ↓
Amazon S3
    ↓
eks/dev/terraform.tfstate

The backend implements:

Remote state storage
Server-side encryption
S3 versioning
Public access blocking
State locking

Local .tfstate files and .terraform/ are excluded from Git.

The provider lock file:

.terraform.lock.hcl

is committed to ensure reproducible provider versions.

Troubleshooting Experience

A major part of this project involved troubleshooting real infrastructure issues.

Examples include:

ImagePullBackOff
CrashLoopBackOff
Pending Pods
ResourceQuota
Helm configuration conflicts
Kubernetes probes
NetworkPolicy
Prometheus target discovery
ServiceMonitor configuration
Alertmanager routing
HPA and Argo CD replica conflicts
Grafana datasource issues
Loki filesystem configuration
LogQL compatibility
Jenkins agents missing Node.js
Kubernetes ephemeral Jenkins agents
Kaniko container builds
Trivy security failures
Git push conflicts caused by automated GitOps commits
Argo CD reconciliation
EKS authentication
EKS Access Entries
AWS VPC quota limits
EKS pod density limits
IAM OIDC connectivity
AWS Load Balancer Controller IRSA
ALB Ingress reconciliation
Terraform state migration

One specific network issue caused the default AWS IAM endpoint to fail TLS negotiation while other AWS services remained reachable.

The project was adapted to use the AWS IAM global API endpoint through a dedicated Terraform provider configuration.

This troubleshooting process provided practical experience beyond simply deploying predefined manifests.

Security Practices

Current security practices include:

Kubernetes RBAC
NetworkPolicy
Dedicated ServiceAccounts
Container security scanning
Git SHA immutable image tags
IRSA for AWS workload identity
Kubernetes Secret usage
No AWS credentials committed to Git
Terraform remote state encryption
S3 public access blocking
GitOps-controlled deployments

Future hardening includes:

runAsNonRoot
readOnlyRootFilesystem
Drop Linux capabilities
Seccomp
Pod Security Standards
External Secrets / Sealed Secrets
PodDisruptionBudget
Pod anti-affinity
Topology spread constraints
Infrastructure Reproducibility

One of the important goals of this project is reproducibility.

Infrastructure can be removed:

terraform destroy

and recreated using:

terraform apply

After the EKS cluster is created:

aws eks update-kubeconfig `
  --region ap-southeast-1 `
  --name devops-kubernetes-project-eks

GitOps and Helm are then used to restore application workloads.

This demonstrates the Infrastructure as Code principle:

Infrastructure should be reproducible from source code,
not dependent on manually created resources.
Key Skills Demonstrated

This project demonstrates hands-on experience with:

Linux containers
Docker
Kubernetes
Helm
Kubernetes networking
Autoscaling
RBAC
Monitoring
Alerting
Centralized logging
SLO engineering
CI/CD
DevSecOps
Jenkins
GitHub Actions
GitOps
Argo CD
Infrastructure as Code
Terraform
AWS VPC
AWS IAM
Amazon EKS
AWS Application Load Balancer
IRSA / OIDC
Terraform remote state
Troubleshooting distributed systems
Next Phase

The next learning phase will focus on:

Ansible

Planned topics:

Inventory
Playbooks
Variables
Handlers
Roles
Idempotency
Package management
Configuration management
Server bootstrap

After Ansible:

Production Hardening
↓
Advanced GitOps
↓
Secret Management
↓
Reliability Testing
↓
Final Portfolio Documentation
Learning Objective

This repository represents a progressive learning journey toward production-oriented DevOps engineering.

The project intentionally combines:

Application
+
Containers
+
Kubernetes
+
CI/CD
+
GitOps
+
Observability
+
Security
+
Infrastructure as Code
+
AWS Cloud

rather than treating each technology as an isolated exercise.

The goal is to understand how these components work together as a complete delivery and operations platform.


### Yang paling penting berubah dari README lama

README lama masih menggambarkan arsitektur utama seperti:

```text
Developer → Docker → Kind → NGINX Ingress

Sekarang project kamu sudah jauh berkembang menjadi:

GitHub
   ↓
Jenkins / GitHub Actions
   ↓
Docker + Kaniko + Trivy
   ↓
GitOps
   ↓
Argo CD
   ↓
Amazon EKS
   ↓
AWS ALB
   ↓
Application

ditambah observability:

Prometheus + Grafana
Loki + Alloy
Alertmanager + Discord
SLO + Error Budget

dan infrastructure:

Terraform
↓
VPC
IAM
EKS
Node Group
OIDC / IRSA
S3 Remote State