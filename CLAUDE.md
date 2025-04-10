# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview
This is a Kubernetes/Helm chart repository for deploying and managing media applications via ArgoCD using GitOps principles.

## Commands
- `helm lint charts/<chart-name>` - Lint a specific chart
- `helm install --dry-run --debug <chart-name> ./charts/<chart-name>` - Test chart rendering without deployment
- `helm template charts/<chart-name>` - Generate and validate chart templates
- `ct lint --all` - Lint all charts using Chart Testing tool
- `kubectl apply -f <filename>.yaml --dry-run=client` - Validate K8s manifest syntax

## Style Guidelines
- YAML: Use 2-space indentation
- Helm: Follow standard template naming (`{{ include "chart.name" . }}`)
- Files: Use lowercase with hyphens for filenames
- Resources: Use CamelCase for Kubernetes resource names
- Templates: Place reusable logic in _helpers.tpl files
- Structure: Group related resources in the same chart
- Annotations/Labels: Consistently apply across all resources
- Comments: Document non-obvious templating logic