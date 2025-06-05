# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a **GitOps homelab infrastructure repository** that uses **ArgoCD ApplicationSets** to manage a Kubernetes cluster. The architecture follows a three-repository pattern:

1. **This repository**: ApplicationSet definitions and Helm chart sources
2. **Charts registry**: Published Helm charts at `https://thoreinstein.github.io/charts`
3. **Values repository**: Environment-specific configurations at `git@github.com:thoreinstein/values.git`

### Service Organization via ApplicationSets

Services are organized into logical groups with specific deployment order:

- **bootstrap_applicationset.yaml**: Core cluster infrastructure (cert-manager, longhorn, sealed-secrets, nvidia-device-plugin)
- **setup_applicationset.yaml**: Networking and base services (ingress-nginx, metrics-server, issuers, ollama)
- **media_applicationset.yaml**: Complete media server stack (plex, sonarr, radarr, tautulli, overseerr, profilarr)
- **other_applicationset.yaml**: Productivity applications (paperless-ngx, miniflux, mealie, karakeep)

### Helm Chart Development Pattern

All charts use the local `common` chart as a dependency for shared patterns:

```yaml
dependencies:
  - name: common
    version: "0.1.0"
    repository: "file://../common"
```

Key shared patterns from common chart:
- `common.domain_name`: Domain name templating
- `common.nfs-volume.tpl`: NFS volume provisioning
- Standard helpers for labels, names, and selectors

## Essential Development Commands

### Helm Chart Development

```bash
# Update chart dependencies
helm dependency update charts/<chart-name>/

# Lint a specific chart
helm lint charts/<chart-name>/

# Template and validate locally (requires values)
helm template <release-name> charts/<chart-name>/ -f /path/to/values.yaml

# Package chart for publishing
helm package charts/<chart-name>/
```

### Chart Publishing Workflow

Charts are published to GitHub Pages registry. After making changes:

```bash
# Package all charts
helm package charts/*/

# Update index (if managing locally)
helm repo index . --url https://thoreinstein.github.io/charts

# Push to trigger GitHub Pages update
git add . && git commit -m "Update charts" && git push
```

### Local Testing and Validation

```bash
# Validate ApplicationSet syntax
kubectl apply --dry-run=client -f <applicationset-file>

# Check ApplicationSet status in cluster
kubectl get applicationset -n argocd

# View generated Applications
kubectl get application -n argocd

# Check specific service deployment
kubectl get all -n <service-namespace>
```

### ArgoCD Management

```bash
# Force sync all applications
argocd app sync -l argocd.argoproj.io/instance=<applicationset-name>

# Refresh application to detect changes
argocd app get <app-name> --refresh

# View application logs
argocd app logs <app-name>
```

## Architecture Patterns

### Multi-Service Deployments

Some charts deploy multiple related services (e.g., karakeep includes chrome + meilisearch). These use:
- Separate deployment templates for each service
- Shared configmaps and secrets
- Internal service discovery via Kubernetes DNS

### Storage Strategy

All persistent data uses NFS-backed PersistentVolumeClaims:
- Storage classes defined in `storage-classes` chart
- NFS server addresses configured per service in values repository
- Automatic PV provisioning for data persistence

### Security Model

- **Sealed Secrets**: All sensitive data encrypted at rest
- **Namespace Isolation**: Each service runs in dedicated namespace
- **Privileged Contexts**: Applied selectively for services requiring host access

### External Access

Services are exposed via:
- **Nginx Ingress**: Internal cluster load balancing
- **Cloudflare Tunnels**: Secure external access without port forwarding
- **LoadBalancer Services**: Direct external IP assignment

## Common Chart Modifications

When adding new services or modifying existing ones:

1. **Update dependencies**: Always run `helm dependency update` after changing common chart
2. **Use common patterns**: Leverage `common.domain_name` and NFS templates
3. **Follow namespace convention**: Service name typically matches namespace name
4. **Configure ingress**: Use consistent annotation patterns for Cloudflare integration
5. **Handle secrets**: Use sealed secrets for any sensitive configuration

## Values Repository Integration

Configuration lives in separate repository for security and flexibility:
- Charts reference values via ApplicationSet generators
- Different environments can use same charts with different values
- Sensitive values are sealed-secret encrypted before committing