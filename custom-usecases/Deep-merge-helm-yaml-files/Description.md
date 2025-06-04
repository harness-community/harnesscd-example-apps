# Deep-Merge Values YAML and Push to Git

This example demonstrates how to perform a deep-merge of multiple Helm values YAML files and push the result to a specific Git branch, all within a single CI step. It consists of two stages:

1. **deepmerge-values**: Clones the `cd-samples` repository, runs a Python-based deep-merge of `values.yaml` and override files, and pushes `merged-values.yaml` to a target branch.  
2. **helm-deploy**: Deploys the chart using the newly merged values file from that branch.

---

## Overview

- **Language/Tooling**: Alpine Linux, Python 3.9, `ruamel.yaml` for YAML processing, Git for source control.  
- **Goal**:  
  1. Combine `mychart/values.yaml` with `overrides/values-db.yaml` and `overrides/values-mem.yaml`, merging maps recursively and concatenating unique list entries.  
  2. Create or reset a branch (e.g. `test1`) in the same repository, commit `merged-values.yaml` there, and force-push.  
- **Use Case**: If you need a single consolidated values file for a downstream Helm deploy—rather than applying multiple override files—this CI step ensures the merged YAML always lives on its own branch and can be referenced by a HelmDeploy step.

---

## deepmerge-values Stage (Build stage)

### Purpose

- Clone the `vishal-av/cd-samples` repo at `main`.  
- Deep-merge three YAML files:  
  1. `mychart/values.yaml` (base)  
  2. `overrides/values-db.yaml` (database overrides)  
  3. `overrides/values-mem.yaml` (memory overrides)  
- Write the result to `merged-values.yaml`.  
- Commit and push `merged-values.yaml` to a user-specified Git branch (e.g. `test1`).

### Key Steps

1. **Install Dependencies**  
   Uses `apk add` to install:  
   - `git` (for repo operations)  
   - `curl`, `tar`, `gzip` (standard utilities)  
   - `python3` and `py3-pip` (to run the merge script)  

2. **Clone the Repository**  
   ```sh
   git clone \
     --branch main \
     --depth 1 \
     "https://${GIT_TOKEN}@github.com/your-account/cd-samples.git" \
     /workspace/cd-samples
   cd /workspace/cd-samples
   ```
- GIT_TOKEN is a secret containing a GitHub PAT with push permissions.

- A shallow clone (--depth 1) minimizes fetch time.

3. **Install `ruamel.yaml`**

```
pip3 install --no-cache-dir ruamel.yaml
ruamel.yaml enables roundtrip YAML parsing, preserving comments and ordering.
```

4. **Write the Deep-Merge Python Script**

```sh
import sys
from ruamel.yaml import YAML

yaml = YAML()

def deep_merge_with_list(base, override):
    if isinstance(base, dict) and isinstance(override, dict):
        for key, value in override.items():
            if key in base:
                base[key] = deep_merge_with_list(base[key], value)
            else:
                base[key] = value
        return base
    elif isinstance(base, list) and isinstance(override, list):
        merged = list(base)
        for item in override:
            if item not in merged:
                merged.append(item)
        return merged
    else:
        return override

def main(files, output_file):
    base = yaml.load(open(files[0]))
    for f in files[1:]:
        override = yaml.load(open(f))
        base = deep_merge_with_list(base, override)
    with open(output_file, 'w') as out:
        yaml.dump(base, out)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python deep_merge_yaml.py base.yaml override1.yaml [override2.yaml ...] output.yaml")
        sys.exit(1)
    *input_files, output = sys.argv[1:]
    main(input_files, output)
```

- Merges nested maps recursively.

- For lists, appends only unique items.

5. Run the Merge

```sh
python3 deep_merge_yaml.py \
  mychart/values.yaml \
  overrides/values-db.yaml \
  overrides/values-mem.yaml \
  merged-values.yaml
```

Produces merged-values.yaml in the repo root.

Example output:

```yaml
abc: xyz
hello: world
foo: bar
features:
  logging: true
  tracing: true
env:
  - dev
  - staging
  - prod
app:
  name: test
  env:
    - dev
    - staging
    - prod
```

6. Configure Git and Push

```sh
git config user.email "<+pipeline.variables.email>"
git config user.name "<+pipeline.variables.github_handle>"
git checkout -B "<+pipeline.variables.git_branch>"
git add merged-values.yaml
git commit -m "chore: add merged-values.yaml on <+pipeline.variables.git_branch>"
git push \
  "https://${GIT_TOKEN}@github.com/vishal-av/cd-samples.git" \
  "<+pipeline.variables.git_branch>" --force
echo "🔥 merged-values.yaml pushed to branch <+pipeline.variables.git_branch>"
```
- Uses pipeline variables to fill in user email, GitHub username, and target branch.

- Force-pushes merged-values.yaml to the specified branch.

## helm-deploy Stage

**Configuration**
- **serviceRef**: `valuesdeepmerge` (the Service that contains both the chart and the merged-values manifest).

- **manifestOverrides** (in the pipeline, not shown above) must set both helmChartManifest and mergedValues to use `<+pipeline.variables.git_branch>` instead of main.

**For complete pipeline yaml, refer to [pipeline.yaml](./pipeline.yaml)**