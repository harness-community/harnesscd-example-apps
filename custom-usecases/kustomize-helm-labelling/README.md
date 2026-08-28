# Kustomize Helm Label Injection

Inject labels onto **every Kubernetes resource** deployed via Helm — without modifying any chart.
Labels are supplied at pipeline run time, scoped per deployment stage, and persist across redeployments.

---

## Problem

Organizations deploying via Helm need to enforce labels (team ownership, cost center, environment)
on all live K8s resources. The common approaches fail:

| Approach | Why it fails |
|---|---|
| `helm install --labels` | Labels go on the Helm release secret only — not actual K8s resources |
| `--set podLabels.*` | Only works if every chart exposes a `podLabels` placeholder |
| `kubectl label` post-deploy | Not part of the manifest — silently wiped on next `helm upgrade` |

**This example uses:** a Kustomize Helm post-renderer. Helm pipes its rendered manifests through a
small script, Kustomize injects the labels, and the labelled output gets applied to the cluster.
No chart edits required.

---

## How It Works

```
pipeline variables (JEXL)
        │
        ▼
setup script runs before deploy → writes post-render-<stage> to delegate
        │
        ▼
helm template → stdin → post-render-<stage> → kustomize labels transformer → stdout → kubectl apply
```

1. A **ShellScript step** runs before deployment. It resolves label values (from stage variables or
   existing cluster labels) and writes a stage-specific post-renderer binary to the delegate.
2. The **K8sRollingDeploy step** runs `helm upgrade --post-renderer /path/post-render-<stage>`,
   piping rendered YAML through Kustomize before applying.
3. Labels are part of the applied manifest — they survive subsequent redeployments.

---

## Label Behaviour Across Runs

| Scenario | What happens |
|---|---|
| **First run** — provide `labelValue=platform-team` | Label applied fresh |
| **Re-run** — provide new `labelValue=data-team` | Label updated to new value |
| **Re-run** — leave `labelValue` blank | Setup script reads existing label from cluster and retains it |
| **First run** — leave `labelValue` blank | No prior label found; defaults to `unspecified` |

---

## Two Usecases

| | [Usecase 1: Inline Script](./usecase-1-inline-script/) | [Usecase 2: File Store](./usecase-2-file-store/) |
|---|---|---|
| **Setup script location** | Inline inside pipeline step | Harness File Store — update once, all pipelines pick it up |
| **Label injection** | JEXL resolved in inline script, labels baked in | JEXL resolved in File Store script, labels baked in |
| **`--post-renderer-args`** | Not needed | Not needed |
| **Parallel stage safety** | Stage-specific script path + race-safe kustomize install | Same |
| **Best for** | Getting started, self-contained pipelines | Production, shared pipelines, centralised script management |

---

## Installing Kustomize on the Delegate

The setup script auto-installs kustomize if missing. In production, install it once at delegate
startup instead.

### Option A: INIT_SCRIPT (recommended)

Set the `INIT_SCRIPT` environment variable on the delegate deployment:

```yaml
INIT_SCRIPT: |
  curl -sSL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.3/kustomize_v5.4.3_linux_amd64.tar.gz \
    | tar -xzf - -C /tmp
  cp -f /tmp/kustomize /opt/harness-delegate/client-tools/kustomize
  chmod 0755 /opt/harness-delegate/client-tools/kustomize
```

Kustomize is installed when the delegate pod starts and is available on every pipeline run.
The setup script's install block is skipped (the version check passes immediately).

### Option B: Bake into delegate image

Add the kustomize install to your delegate Dockerfile. Most stable option for large fleets.

### Option C: Setup script install (demo / low-volume)

The setup script checks and installs kustomize on first use. Fine for demos but adds a download
step on cold-start runs.

---

## Delegate Affinity: Setup Step + K8s Deploy Step

The setup script writes the post-renderer binary to the local delegate filesystem. The
K8sRollingDeploy step must run on the **same delegate instance** that wrote it.

**Simplest fix:** pin both steps to the same delegate using `delegateSelectors`:

```yaml
- step:
    type: ShellScript
    spec:
      delegateSelectors:
        - my-delegate-tag
- step:
    type: K8sRollingDeploy
    spec:
      delegateSelectors:
        - my-delegate-tag
```

**Dynamic option** (advanced): export `HOSTNAME` from the setup step as an output variable and
reference it in the K8s step's `delegateSelectors`. This avoids hardcoding but requires wiring
output variables and is more complex to maintain.

```bash
# In delegate — export hostname as output variable
export SELECTED_DELEGATE=$HOSTNAME
```

Note: inheriting the ShellScript step's delegate in the K8sRollingDeploy step is not directly
supported today — steps need the selector declared explicitly.

---

## Helm v4 Compatibility

Post-renderer scripts are saved **without a `.sh` extension**
(`post-render-<stage>` instead of `post-render-<stage>.sh`).
The `--post-renderer` path in service commandFlags never changes across Helm versions —
only the delegate install script changes if Helm v4 adjusts the post-renderer interface.

---

## Folder Structure

```
kustomize-helm-labelling/
├── README.md                          ← this file
├── helm-chart/                        ← shared demo chart (no label placeholders — intentional)
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       └── service.yaml
├── usecase-1-inline-script/           ← setup script inline in pipeline
│   ├── README.md
│   ├── pipeline.yaml
│   └── service.yaml
└── usecase-2-file-store/              ← setup script in Harness File Store
    ├── README.md
    ├── pipeline.yaml
    ├── service.yaml
    └── file-store/
        └── setup-post-renderer        ← paste content into Harness File Store
```

---

## Requirements

- **Kubernetes**: 1.21+
- **Helm**: 3.x on delegate
- **Kustomize**: 5.x (installed via INIT_SCRIPT, delegate image, or by setup script)
- **Deployment type**: `Kubernetes` (K8sRollingDeploy — not NativeHelm)
- **Chart compatibility**: any chart, unmodified