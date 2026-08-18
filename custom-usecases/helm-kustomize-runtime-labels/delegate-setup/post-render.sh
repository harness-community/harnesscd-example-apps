#!/usr/bin/env bash
# Helm post-renderer script — runtime-labels variant
#
# Place this file on your Harness delegate at:
#   /opt/harness-delegate/client-tools/post-render.sh
# and make it executable:
#   chmod +x /opt/harness-delegate/client-tools/post-render.sh
#
# How it works:
#   Helm pipes rendered manifests to this script on stdin.
#   Label values arrive as positional args via `helm --post-renderer-args`,
#   which Harness populates from pipeline variables at execution time.
#   Kustomize applies the label transformer and prints the result on stdout.
#   Harness then applies that output to the cluster.
#
# Unlike the fixed-labels example, nothing is hardcoded here — the caller
# (the pipeline run) decides the label values every time. Requires Helm 3.9+
# on the delegate (--post-renderer-args was added in that release).
#
# Requires: kustomize on the delegate PATH or at
#   /opt/harness-delegate/client-tools/kustomize

set -euo pipefail

KUSTOMIZE=$(command -v kustomize || true)
[ -z "$KUSTOMIZE" ] && [ -x /opt/harness-delegate/client-tools/kustomize ] \
  && KUSTOMIZE=/opt/harness-delegate/client-tools/kustomize

if [ -z "$KUSTOMIZE" ]; then
  echo "ERROR: kustomize not found. Install it on the delegate." >&2
  exit 1
fi

# Positional args, in the order they're passed via --post-renderer-args
# in the service's commandFlags. Falls back to "unspecified" so the
# script still runs (and the gap is visible on the resource) if a
# pipeline variable was left blank.
TEAM="${1:-unspecified}"
COST_CENTER="${2:-unspecified}"
ENVIRONMENT="${3:-unspecified}"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# Helm's rendered YAML arrives on stdin
cat > "$WORK/all.yaml"

cat > "$WORK/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - all.yaml
# includeSelectors: false  → labels are NOT added to selector fields,
#                            keeping them immutable across redeploys.
# includeTemplates: true   → labels ARE added to pod templates,
#                            so pods carry them (required for monitoring/netpol).
labels:
  - includeSelectors: false
    includeTemplates: true
    pairs:
      team: ${TEAM}
      cost-center: ${COST_CENTER}
      managed-by: harness
      environment: ${ENVIRONMENT}
EOF

"$KUSTOMIZE" build "$WORK"
