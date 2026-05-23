# AI Agent Guide: home-server-helm

This is a GitOps repository for deploying a complete home server infrastructure using Kubernetes, Helm, Flux CD, and ArgoCD.

## Project Overview

**home-server-helm** manages a collection of Helm charts that deploy:
- Infrastructure components (Cilium networking, cert-manager, storage, etc.)
- Media services (Plex, Radarr, Bazarr, Sonarr, Readarr)
- Development tools (GitLab, Vault, Harbor registry)
- Monitoring (Prometheus, Grafana via kube-prometheus-stack)
- GitOps controllers (Flux CD, ArgoCD)

**Deployment Pattern:** Flux CD reads from this repository → deploys using `charts/flux-resources` → ArgoCD manages individual Helm releases

## Directory Structure

```
charts/
├── flux-resources/           # 🔑 Central GitOps deployment chart
│   ├── Chart.yaml
│   ├── values.yaml          # Empty (values per environment)
│   └── templates/
│       ├── argocd/
│       ├── bazarr/
│       ├── cert-manager/
│       ├── cilium/
│       └── ... (one subdirectory per deployed chart)
│
├── [service-name]/           # Individual Helm charts for each service
│   ├── Chart.yaml           # Chart metadata with dependencies
│   ├── values.yaml          # Service-specific values
│   ├── charts/              # Helm dependency tarballs
│   └── templates/
│       ├── _helpers.tpl     # Template helpers
│       ├── config-map-*.yaml
│       ├── stateful-set.yaml or deployment.yaml
│       ├── service.yaml
│       ├── httproute.yaml   # Cilium Gateway API routes
│       └── vault-*.yaml     # Vault secret references
│
.flux/
├── git-repository-home-server.yaml  # Flux GitRepository source
└── flux-resources/                   # Flux Kustomization for flux-resources chart
.backstage/
└── catalog-[service].yaml           # Backstage component catalogs
[env].values.yaml                     # Environment-specific overrides (dev, prod)
```

## Key Concepts

### 1. **flux-resources Chart**
The central orchestration point. This chart does NOT implement services itself. Instead, it:
- Contains ArgoCD `Application` resources in `templates/[service-name]/application.yaml`
- Each Application pulls a Helm chart from this repository
- Template subdirectories mirror the chart structure for organization

**Important:** Do NOT create new Helm chart implementations in `charts/flux-resources/templates/`. This chart is ONLY for deploying other charts.

### 2. **Chart Dependencies**
Service charts declare their dependencies in `Chart.yaml`:
```yaml
dependencies:
- name: [upstream-chart]
  version: ">=X.Y.Z"
  repository: https://[chart-repo-url]
```

Run `helm dependency update charts/[service-name]` to fetch tarballs into `charts/`.

### 3. **Vault Integration**
Most charts include `templates/vault-secrets.yaml` that creates `VaultStaticSecret` resources:
- Syncs credentials from HashiCorp Vault to Kubernetes secrets
- Used by deployments via `envFrom` and `volumeMounts`
- Path format: `mount:kv/type:kv-v2/path:service-name/secret-key`

### 4. **Network Exposure**
Services expose via Cilium Gateway API (not Ingress):
- External gateway: `gateway-external` with TLS termination
- Internal gateway: `gateway-internal` for cluster-internal access
- Templates: `templates/httproute.yaml` defines routes

### 5. **Configuration Patterns**
Each service chart typically includes:
- `config-map-env.yaml`: Environment variables (ConfigMap)
- `stateful-set.yaml` or `deployment.yaml`: Workload definition
- `service.yaml`: ClusterIP service for discovery
- `vault-secrets.yaml`: Secret management
- `_helpers.tpl`: Template function `{{- include "commonLabels" . }}` for consistent labeling

## Common Labels Convention

All resources include standard labels via `commonLabels` template helper:
```yaml
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ version }}
backstage.io/kubernetes-id: [service-name]  # For Backstage discovery
```

## Deployment Flow

1. **Flux GitRepository** (`.flux/git-repository-home-server.yaml`)
   - Watches this repository for changes
   - Pulls only `charts/` and `.flux/` directories

2. **Flux Kustomization** (`.flux/flux-resources/`)
   - Deploys `charts/flux-resources` Helm chart
   - Triggers ArgoCD Application resources

3. **ArgoCD Applications** (`charts/flux-resources/templates/[service]/application.yaml`)
   - Each Application references a service chart
   - ArgoCD syncs the Helm release to the cluster
   - CRD: `apiVersion: argoproj.io/v1alpha1`

## Environment Management

- **`dev.values.yaml`**: Development environment overrides
- **`prod.values.yaml`**: Production environment overrides (IP pools, volumes, resource limits)

These are typically merged at deployment time via Flux or ArgoCD value merges.

## Unused Code Patterns to Look For

When scanning for unused code:
1. **Orphaned templates** in `charts/[service]/templates/` not referenced in the Helm release
2. **Dead helper functions** in `_helpers.tpl` not called by any template
3. **Unused values** in `values.yaml` not consumed by templates
4. **Duplicate service definitions** (e.g., multiple charts for the same service: `forbes-*`, `mad-*`)
5. **Chart.yaml dependencies** without corresponding templates or references
6. **Unused environment-specific values** in `dev.values.yaml` or `prod.values.yaml`

## Useful Commands

```bash
# Validate all charts
for chart in charts/*/; do helm lint "$chart" || echo "FAILED: $chart"; done

# Check Helm template rendering
helm template [release-name] charts/[service-name] -f [env].values.yaml

# Validate Kubernetes manifests
helm template [release-name] charts/[service-name] | kubeval

# Check for chart dependencies
find charts -name Chart.yaml -exec grep -l "dependencies:" {} \;

# List all ArgoCD applications
find charts/flux-resources/templates -name "application.yaml"
```

## Conventions

### Chart Names
- Snake-case chart directories: `azure-devops-agent`, `kube-prometheus-stack`
- Helm release names typically match chart names
- Multiple instances of same service: `mad-bazarr`, `forbes-bazarr` (separate namespaces)

### Namespaces
- Services deployed to namespace matching chart name (e.g., `bazarr`, `minio`)
- System components in `kube-system` (cilium, metrics-server)

### Image Registries
- Harbor registry mirror: `harbor.nwallace.io/[registry]/[image]`
- All images configured in `values.yaml`

## Key Files to Examine for Understanding

- [charts/flux-resources/Chart.yaml](charts/flux-resources/Chart.yaml) - Central deployment chart
- [.flux/git-repository-home-server.yaml](.flux/git-repository-home-server.yaml) - Flux source
- [catalog-info.yaml](catalog-info.yaml) - Backstage metadata
- [prod.values.yaml](prod.values.yaml) - Production network and volume config
- Any chart's [_helpers.tpl](charts/bazarr/templates/_helpers.tpl) - Label convention

## Common Pitfalls

- **Don't modify flux-resources implementation**: This chart only orchestrates others; chart implementations live in `charts/[service]/`
- **Don't miss Vault integration**: Charts expect `VaultStaticSecret` resources to inject credentials; verify they exist before deploying
- **Watch for helm dependency version pins**: Chart upgrades may require `helm dependency update`
- **Gateway API config**: External/internal gateways are shared; adding routes requires modifying the right gateway in `cilium` chart
- **Multiple instances**: Services like Bazarr/Radarr have variants (`mad-`, `forbes-`); ensure template changes propagate correctly
