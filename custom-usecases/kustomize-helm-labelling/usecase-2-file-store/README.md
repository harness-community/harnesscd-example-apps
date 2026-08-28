# Usecase 2: File Store Script

The setup script lives in **Harness File Store** (`/setup-post-renderer`). The pipeline
ShellScript step fetches and executes it using `source.type: Harness`. Update the script once in
File Store — every pipeline that references it picks up the change automatically.

---

## Changes vs Usecase 1

| | Usecase 1 (inline) | Usecase 2 (File Store) |
|---|---|---|
| **Script location** | Inline in pipeline YAML | Harness File Store |
| **Update path** | Edit pipeline YAML | Edit one file in File Store |
| **JEXL resolution** | Resolved inline before script runs on delegate | Resolved by Harness when fetching File Store script — same result |
| **Everything else** | — | Identical (same label logic, same parallel safety, same commandFlags) |

---

## File Store Setup

1. In your Harness project, go to **File Store**
2. Create a new file at root level:
   - **Name**: `setup-post-renderer`
   - **File Usage**: Script
3. Paste the contents of [`file-store/setup-post-renderer`](./file-store/setup-post-renderer) into the editor
4. Save — the pipeline references it as `file: /setup-post-renderer`.

---

## Flow

```
pipeline run triggered
        │
        ▼
ShellScript step (source: Harness File Store /setup-post-renderer)
  Harness resolves JEXL (<+stage.variables.labelValue> etc.) before sending to delegate
  Script runs on delegate:
    - resolves label values (provided → retain → unspecified)
    - installs kustomize if missing
    - writes post-render-<stage.identifier> to delegate
        │
        ▼
K8sRollingDeploy
  helm upgrade --post-renderer /opt/.../post-render-<stage.identifier>
        │
        ▼
Verify Labels
```

---

## Files

- [`pipeline.yaml`](./pipeline.yaml) — identical structure to usecase 1, ShellScript step uses
  `source.type: Harness`
- [`service.yaml`](./service.yaml) — same as usecase 1
- [`file-store/setup-post-renderer`](./file-store/setup-post-renderer) — paste into Harness File Store

---

## Setup

1. Create the File Store script (see above)
2. Push `helm-chart/` to your Git repo
3. Import `service.yaml` and `pipeline.yaml`
4. Run the pipeline