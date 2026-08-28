# Usecase 1: Inline Shell Script

The setup script that creates the post-renderer lives **inline** inside the pipeline's ShellScript
step. Everything is self-contained in the pipeline YAML.

---

## Flow

```
pipeline run triggered
        │
        ▼
ShellScript step (inline)
  - resolves labelValue / costCenter from stage variables
  - if blank → reads existing label from cluster (retention)
  - installs kustomize if missing
  - writes post-render-<stage.identifier> to delegate
        │
        ▼
K8sRollingDeploy
  helm upgrade --post-renderer /opt/.../post-render-<stage.identifier>
  Helm renders chart → pipes through post-renderer → Kustomize adds labels → kubectl apply
        │
        ▼
Verify Labels (ShellScript)
  kubectl get all -n <namespace> --show-labels
```

---

## What the Setup Script Does

The inline script in the pipeline step:

1. **Resolves label values** — uses the provided stage input, reads the existing label from the
   cluster if blank, or defaults to `unspecified` on first run
2. **Installs kustomize** if not already present (race-safe: uses `mktemp -d` per process +
   `cp -f` to overwrite safely)
3. **Writes the post-renderer** to `$TOOLS/post-render-<stage.identifier>` using a two-part heredoc:
   - `'STATIC_EOF'` (single-quoted) writes shell boilerplate literally, with no variable expansion
   - `DYNAMIC_EOF` (unquoted) — expands `${LABEL_VALUE}` and `${COST_CENTER}`, baking resolved
     values into the `kustomization.yaml` the post-renderer binary reads

Helm's rendered YAML arrives on stdin, the post-renderer writes a `kustomization.yaml` with
baked-in label values, runs `kustomize build`, and prints to stdout.

---

## Parallel Stage Safety

If two stages deploy in parallel on the same delegate:
- Each stage writes its own `post-render-<stage.identifier>` path — no filename collision
- Kustomize install uses `mktemp -d` (unique temp dir per process) + `cp -f` — no shared
  `/tmp/kustomize` race
- Label values are stage-scoped (`<+stage.variables.labelValue>`) — each stage carries its own values

---

## Files

- [`pipeline.yaml`](./pipeline.yaml) — single-stage pipeline; extend for parallel stages in
  multi-service deployments
- [`service.yaml`](./service.yaml) — Harness service with `--post-renderer` commandFlags
  (no `--post-renderer-args`)

---

## Setup

1. Push `helm-chart/` to your Git repo and note the folder path
2. Import `service.yaml` — fill in `connectorRef`, `folderPath`, `branch`
3. Import `pipeline.yaml` — wire service, environment, infrastructure
4. Ensure the delegate `delegateSelectors` tag used in the pipeline matches your delegate

---

## Verifying Labels After Deploy

```bash
kubectl get all -n <namespace> --show-labels
```