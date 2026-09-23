# Usecase 3: Post-Renderer Script Cleanup

After a Helm deployment using a Kustomize post-renderer, the setup script leaves a small binary on
the delegate's local filesystem (`/opt/harness-delegate/client-tools/post-render-<stage>.sh`).
This usecase shows how to clean it up automatically as part of the same pipeline — no manual
intervention required.

---

## Why Clean Up?

The post-renderer script is written to the delegate on every deployment run. If left in place:

- It accumulates over time, one file per stage identifier per delegate pod
- On delegate pod restarts the filesystem is wiped anyway, but long-lived delegates will collect
  stale scripts

Cleanup is lightweight — one shell step — and belongs in the **same pipeline** as the deployment
so it always runs in the right context.

> **Anti-pattern to avoid:** a standalone cleanup pipeline that accepts namespace and delegate
> as inputs. That forces the user to track which delegate handled the deploy, reintroduces the
> pod-affinity problem, and runs outside the deployment's own lifecycle. Keep cleanup in the same
> pipeline.

---

## How It Works

The cleanup runs in a **Custom stage** after the K8s deploy stage completes:

```
pipeline run triggered
        │
        ▼
Stage 1: Deploy with Label Injection (Deployment stage)
  ShellScript — fetches setup-post-renderer from File Store
    → writes post-render-deploy_with_labels.sh to delegate local filesystem
        │
        ▼
  K8sRollingDeploy
    helm upgrade --post-renderer post-render-deploy_with_labels.sh
    Kustomize injects labels onto all resources
    Waits for pod readiness (steady state) before completing
        │
        ▼
Stage 2: Approve Cleanup (Approval stage)
  Pauses for manual confirmation — verify labels are applied correctly
  before allowing cleanup to proceed
        │
        ▼
Stage 3: Cleanup Post-Renderer Script (Custom stage)
  ShellScript — removes post-render-deploy_with_labels.sh from delegate
```

K8sRollingDeploy waits for pods to reach ready state before it completes, so the approval gate
only appears after a healthy deployment. The approval gives you a window to inspect the cluster
before the script is removed.

---

## Delegate Selector: Why All Three Steps Need It

The setup script writes the post-renderer binary to the **local filesystem of whichever delegate
pod runs that step**. If any subsequent step lands on a different pod (delegates can have multiple
replicas), it looks at a different filesystem and either fails to find the script or fails to
clean it up.

**Pin all three steps to the same delegate using `delegateSelectors`:**

| Step | Why it needs the selector |
|---|---|
| `ShellScript` (setup) | Writes the script to local disk — must be the same pod that deploys |
| `K8sRollingDeploy` | Calls the script via `--post-renderer` — must find it on disk |
| `ShellScript` (cleanup) | Deletes the script — must look on the same pod that wrote it |

```yaml
# Apply this to all three steps
delegateSelectors:
  - your-delegate-tag
```

---

## Changes vs Usecase 2

| | Usecase 2 (File Store) | Usecase 3 (File Store + Cleanup) |
|---|---|---|
| **Post-deploy** | Script stays on delegate | Script removed from delegate |
| **Stage count** | 1 (Deployment) | 3 (Deployment + Approval + Custom) |
| **Approval gate** | — | Between deploy and cleanup — verify labels before script is removed |
| **Custom stage** | — | Required — Deployment stage type does not support `finallySteps` |
| **Cleanup failure** | — | Ignored by default — a missing script should not fail the pipeline |
| **Everything else** | — | Identical |

---

## Script Filename Convention

The setup script names the post-renderer file after the **deploy stage identifier**:

```
/opt/harness-delegate/client-tools/post-render-<stage-identifier>.sh
```

If you rename the deploy stage (`deploy_with_labels` → something else), update the path in the
cleanup step to match. The stage identifier is set in `pipeline.yaml` under `identifier:` on the
deploy stage.

---

## Files

- [`pipeline.yaml`](./pipeline.yaml) — two-stage pipeline: Deploy + Cleanup

---

## Setup

1. Complete the [Usecase 2 setup](../usecase-2-file-store/README.md) first — this usecase reuses
   the same File Store script, service, and infrastructure
2. Import `pipeline.yaml` into your Harness project
3. Set runtime inputs when running: `serviceRef`, `environmentRef`, `infrastructureDefinitions`,
   `delegateSelectors`, and optionally `labelValue` / `costCenter`
4. Run the pipeline — after the deployment completes and reaches steady state, the cleanup stage
   removes the post-renderer script automatically
