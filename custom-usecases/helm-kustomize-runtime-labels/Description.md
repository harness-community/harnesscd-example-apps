# Helm Runtime Label Injection via Kustomize Post-Renderer

This example demonstrates how to inject labels supplied **at pipeline run time** onto every Kubernetes resource deployed via Helm — without modifying any Helm chart. Unlike [helm-kustomize-post-renderer](../helm-kustomize-post-renderer/), where labels are fixed centrally, here the caller triggering the pipeline decides the label values on each run.

---

## Problem Statement

Sometimes label values aren't known ahead of time or shouldn't be centrally fixed — for example, a shared deployment pipeline used by multiple teams, where each run needs to be tagged with the requesting team, cost center, or a per-run environment tag. The [fixed-labels example](../helm-kustomize-post-renderer/) solves "same labels on everything." This example solves "caller decides the labels, per run" — while keeping the same core guarantees:

- **No chart edits** — the chart still has zero label placeholders
- **Persistent** — labels are part of the applied manifest, not a post-deploy patch
- **Caller-controlled** — no editing a script on the delegate to change a label; just fill in the pipeline's runtime inputs

---

## Solution: Runtime Args Through the Post-Renderer

Same pipe as the fixed-labels example, but the label values travel through the pipeline instead of being hardcoded in the script:

```
pipeline variables (runtime input)
        │
        ▼
service commandFlags: --post-renderer-args=...
        │
        ▼
helm template  →  (stdin)  →  post-render.sh  →  kustomize labels transformer  →  (stdout)  →  kubectl apply
```

- Helm's `--post-renderer-args` flag (Helm 3.9+) passes positional arguments to the post-renderer binary
- Harness resolves `<+pipeline.variables.*>` expressions in the service's `commandFlags` before invoking Helm, so the script receives the actual values the user typed in at trigger time
- `post-render.sh` reads those as `$1`, `$2`, `$3` and builds the Kustomize `pairs:` block dynamically — nothing is hardcoded

---

## How It Works

### 1. Pipeline Variables (Runtime Inputs)

```yaml
variables:
  - name: team
    type: String
    value: <+input>
  - name: costCenter
    type: String
    value: <+input>
  - name: environment
    type: String
    value: <+input>
```

Whoever triggers the pipeline fills these in (UI form, API payload, or trigger config).

### 2. Passing Values Through commandFlags

```yaml
commandFlags:
  - commandType: Upgrade
    flag: >-
      --post-renderer /opt/harness-delegate/client-tools/post-render.sh
      --post-renderer-args=<+pipeline.variables.team>
      --post-renderer-args=<+pipeline.variables.costCenter>
      --post-renderer-args=<+pipeline.variables.environment>
```

Each `--post-renderer-args` becomes one positional argument to the script, in order.

### 3. The Post-Renderer Script

`delegate-setup/post-render.sh` reads the positional args instead of hardcoded values:

```bash
TEAM="${1:-unspecified}"
COST_CENTER="${2:-unspecified}"
ENVIRONMENT="${3:-unspecified}"
```

Everything else — capturing stdin, writing a temporary `kustomization.yaml`, running `kustomize build`, printing to stdout — is identical to the fixed-labels example.

```yaml
labels:
  - includeSelectors: false    # do NOT add to selector fields (keeps them immutable)
    includeTemplates: true     # DO add to pod templates (so pods carry the labels)
    pairs:
      team: ${TEAM}
      cost-center: ${COST_CENTER}
      managed-by: harness       # stays static — identifies the tool, not caller-controlled
      environment: ${ENVIRONMENT}
```

For complete service YAML, refer to [service.yaml](./service.yaml)

---

## Folder Structure

```
helm-kustomize-runtime-labels/
├── Description.md              # this file
├── pipeline.yaml                # pipeline with team/costCenter/environment as runtime inputs
├── service.yaml                 # Harness service with runtime post-renderer args
├── delegate-setup/
│   └── post-render.sh           # the post-renderer script — place on your delegate
└── helm-chart/                  # minimal demo chart (no label placeholders — intentional)
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        └── service.yaml
```

---

## Setup Instructions

### Step 1: Install kustomize on the delegate

```bash
# exec into your delegate pod
kubectl exec -it <delegate-pod> -n <delegate-namespace> -- bash

# download kustomize
curl -sSL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.3/kustomize_v5.4.3_linux_amd64.tar.gz \
  | tar -xz -C /tmp
install -m 0755 /tmp/kustomize /opt/harness-delegate/client-tools/kustomize

# verify
/opt/harness-delegate/client-tools/kustomize version
```

### Step 2: Confirm the delegate's Helm version supports --post-renderer-args

```bash
/opt/harness-delegate/client-tools/helm version
```

Requires Helm **3.9 or later**. If your delegate ships an older Helm, upgrade it before using this example — `--post-renderer-args` will otherwise be silently unrecognized.

### Step 3: Place the post-renderer script on the delegate

```bash
kubectl cp delegate-setup/post-render.sh \
  <delegate-namespace>/<delegate-pod>:/opt/harness-delegate/client-tools/post-render.sh

chmod +x /opt/harness-delegate/client-tools/post-render.sh
```

> **For production:** bake both `kustomize` and `post-render.sh` into the delegate image or the delegate's `INIT_SCRIPT` environment variable so they survive pod restarts.

### Step 4: Push the Helm chart to your GitHub repo

Upload the contents of `helm-chart/` to a folder in your Git repository. Note the folder path — you will reference it in the service's `folderPath` field.

### Step 5: Create the Harness service

Import [service.yaml](./service.yaml) and fill in:
- `connectorRef` — your GitHub connector
- `folderPath` — path to the chart folder in your repo
- `branch` — your default branch (e.g. `main`)

### Step 6: Import the pipeline

Import [pipeline.yaml](./pipeline.yaml) and wire it to the service, environment, and infrastructure you created.

### Step 7: Create the target namespace

```bash
kubectl create namespace <your-namespace>
```

### Step 8: Trigger with runtime label values

Run the pipeline and fill in `team`, `costCenter`, and `environment` in the runtime-input form. Different runs can carry different label values without touching the chart, the service, or the delegate script.

---

## Verification

After the pipeline runs, confirm labels on live resources:

```bash
kubectl get deploy,svc,pod -n <namespace> --show-labels
```

The values should match whatever was entered in the pipeline's runtime-input form for that run — not a fixed set baked into a script.

---

## Label Schema

| Pipeline variable | Injected label | Caller-controlled? |
|---|---|---|
| `team` | `team` | Yes — runtime input |
| `costCenter` | `cost-center` | Yes — runtime input |
| `environment` | `environment` | Yes — runtime input |
| — | `managed-by: harness` | No — static, identifies the deployment tool |

---

## Key Differences vs Other Examples

| | [helm-labeling](../helm-labeling/) | [helm-kustomize-post-renderer](../helm-kustomize-post-renderer/) | This example |
|---|---|---|---|
| **Mechanism** | `--set commonLabels.*` via chart values | Kustomize post-renderer, fixed script | Kustomize post-renderer, runtime args |
| **Chart changes required** | Yes — chart must have `commonLabels` placeholder | No | No |
| **Label source** | Chart values / pipeline flags | Hardcoded in `post-render.sh` | Pipeline runtime inputs, per run |
| **Central management** | Flags in service manifest | Single script on delegate | Pipeline variables, per trigger |
| **Best for** | Charts you own/control | Fixed org-wide labels across all runs | Shared pipelines where each run needs different labels |

---

## Requirements

- **Kubernetes**: 1.21+
- **Helm**: **3.9+** on the delegate (required for `--post-renderer-args`)
- **Kustomize**: 5.x (installed on delegate — see Step 1)
- **Deployment type**: `Kubernetes` (K8sRollingDeploy, not NativeHelm)
- **Chart compatibility**: None — works with any chart unchanged

---

## Related Documentation

- [Helm Post-Renderer Documentation](https://helm.sh/docs/topics/advanced/#post-rendering)
- [Kustomize Labels Transformer](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/labels/)
- [Harness Native Helm Deployment](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/helm/helm-cd-quickstart/)
- [Harness K8s Rolling Deployment](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/kubernetes/kubernetes-executions/create-a-kubernetes-rolling-deployment/)
