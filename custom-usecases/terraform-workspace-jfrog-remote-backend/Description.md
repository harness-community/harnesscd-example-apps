# Terraform Cloud Workspace Bootstrap with Remote Backend (Harness CI)

This pipeline demonstrates how to **dynamically create or select a Terraform workspace**, and **run a Terraform plan and apply** using **Harness Pipeline**. It integrates with **Terraform Cloud (TFC)** as the execution engine and uses **remote state storage** in a supported backend (e.g., JFrog, Terraform Cloud, etc.).

---

##  What This Pipeline Does

1. Accepts a `WORKSPACE_SUFFIX` as runtime input to define a target workspace (e.g., `dev`).
2. Initializes the Terraform backend.
3. Automatically selects the first available remote workspace (if prompted).
4. Dynamically creates a new workspace if it does not already exist.
5. Runs `terraform plan` and `apply` in that workspace.

---

##  Pre-requisites

### 1. Secrets Configured in Harness

Ensure the following secrets are configured:
- `harness_jfrog_identity_token`: Token to authenticate with your Terraform backend (e.g., `harness.jfrog.io`).

### 2. At Least One Workspace Must Exist Remotely

Before this pipeline runs, you must ensure that **at least one workspace already exists** in your remote backend (e.g., JFrog or Terraform Cloud).

**Why?**

Terraform prompts for workspace selection (`terraform init`) only when multiple workspaces exist. If **none exist**, `terraform init` will fail with an error and halt the pipeline.

You can manually create a placeholder workspace ahead of time, or bootstrap one via a different initialization process.

---

## Pipeline Variables

| Variable           | Description                              |
|--------------------|------------------------------------------|
| `WORKSPACE_SUFFIX` | Suffix used to dynamically name the workspace (e.g., `dev20`) |

---

##  Terraform Code (`main.tf`)

This Terraform code is stored in a **Harness Code Repository** and is cloned using the **CI Build stage** of the pipeline.

```hcl
terraform {
  backend "remote" {
    hostname     = "harness.jfrog.io"
    organization = "da-dev-tf-test"
    workspaces {
      prefix = "mypref-"
    }
  }
}

provider "local" {}

resource "local_file" "test_file" {
  content  = "This is a test file created by Terraform!"
  filename = "terraform_output.txt"
}
```

---

##  Pipeline Shell Script Breakdown

```sh
export TF_TOKEN_harness_jfrog_io="<+secrets.getValue("harness_jfrog_identity_token")>"
WORKSPACE_NAME=<+pipeline.variables.WORKSPACE_SUFFIX>
```
- Sets the authentication token required for Terraform CLI to connect to the remote backend (`harness.jfrog.io`).
- Dynamically constructs the workspace name using the provided suffix.

---

```sh
rm -rf .terraform
printf "1\n" | terraform init -reconfigure
```
- Cleans up previous Terraform state/cache.
- Initializes the backend and **auto-selects the first workspace** in non-interactive mode to skip manual input.

---

```sh
if terraform workspace list | grep -q "${WORKSPACE_NAME}"; then
  terraform workspace select "${WORKSPACE_NAME}"
else
  terraform workspace new "${WORKSPACE_NAME}"
fi
```
- Lists available workspaces.
- Selects the target workspace if it exists, or creates it if not.

---

```sh
terraform plan
terraform apply -auto-approve
```
- Runs the Terraform plan and immediately applies it without manual approval.

---

##  Example

If you input:
```yaml
WORKSPACE_SUFFIX: dev20
```

The pipeline will:
- Attempt to initialize Terraform in the backend
- Automatically pick the first available workspace
- Create/select the workspace `mypref-dev`
- Apply the Terraform configuration

---

##  Notes

- The backend configuration (`main.tf`) is stored in the codebase and must be cloned by the pipeline build stage.
- This setup assumes you're working with CLI-driven Terraform execution, **not remote execution in TFC**.

---

##  YAML references

- YAML for [step-template](./template.yaml)

- YAML for [Harness Pipelines](./pipeline.yaml)
