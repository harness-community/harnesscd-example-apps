#!/usr/bin/env bash
# Helm post-renderer script
#
# Place this file on your Harness delegate at:
#   /opt/harness-delegate/client-tools/post-render.sh
# and make it executable:
#   chmod +x /opt/harness-delegate/client-tools/post-render.sh
#
# How it works:
#   Helm pipes rendered manifests to this script on stdin.
#   Kustomize applies the label transformer and prints the result on stdout.
#   Harness then applies that output to the cluster.
#
# Labels are defined ONLY in this file — edit once to affect every deployment.
# No changes to any Helm chart are required.
#
# Requires: kustomize on the delegate PATH or at
#   /opt/harness-delegate/client-tools/kustomize
# Install: curl -sSL https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash
# Then:    mv kustomize /opt/harness-delegate/client-tools/kustomize

set -euo pipefail

KUSTOMIZE=$(command -v kustomize || true)
[ -z "$KUSTOMIZE" ] && [ -x /opt/harness-delegate/client-tools/kustomize ] \
  && KUSTOMIZE=/opt/harness-delegate/client-tools/kustomize

if [ -z "$KUSTOMIZE" ]; then
  echo "ERROR: kustomize not found. Install it on the delegate." >&2
  exit 1
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# Helm's rendered YAML arrives on stdin
cat > "$WORK/all.yaml"

cat > "$WORK/kustomization.yaml" <<'EOF'
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
      team: backend
      cost-center: eng-platform
      managed-by: harness
      environment: dev
EOF

"$KUSTOMIZE" build "$WORK"
