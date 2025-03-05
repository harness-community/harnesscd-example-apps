# Dynamic ASG Deployment with Multi-Environment and Infrastructure Mapping in Harness

## Overview
This pipeline facilitates **Auto Scaling Group (ASG) deployments** across multiple environments dynamically in **Harness CI/CD**. It fetches environment names, retrieves corresponding infrastructure details via an API, and deploys services based on valid environment-infrastructure combinations.

## Features
- **Matrix Strategy Execution:** Iterates over multiple environments and segments dynamically.
- **API Integration:** Fetches infrastructure identifiers based on environment names.
- **Dynamic Validation:** Ensures only valid environment-infrastructure combinations proceed to deployment.
- **Conditional Deployment:** Deploys only when the environment and infrastructure match predefined valid combinations.

## Pipeline Stages
### 1. **Custom Stage (custom_1) - Extract Environment Names**
- Runs a **ShellScript step** to generate environment names dynamically using Harness expressions.
- Uses **matrix strategy** to iterate over environments and segments.

### 2. **Custom Stage (custom_2) - Fetch Infrastructure Details**
- Extracts environment names from `custom_1` using **JQ parsing**.
- Calls an **API to fetch infrastructure identifiers** for each environment.
- Stores results in **comma-separated variables** (`ENV_NAMES`, `INFRA_LIST`, `VALID_COMBINATIONS`).

### 3. **Deployment Stage (s1) - ASG Deployment**
- Uses **matrix strategy** to iterate over environment-infrastructure pairs.
- Deploys the **ASG service** only if the environment-infrastructure pair exists in `VALID_COMBINATIONS`.

## Variables
| Variable Name         | Description                              | Value Source |
|----------------------|----------------------------------|----------------------|
| `Segments`          | Segments for matrix execution   | User Input (cpe, css, cie) |
| `Qualifiers`        | Qualifiers for naming           | User Input (chi) |
| `Environments`      | List of environments            | User Input (dev, sit, rit) |
| `env_names`        | Extracted environment names     | `custom_2` output |
| `infra_name`       | Retrieved infrastructure names  | `custom_2` output |
| `valid_combinations` | Valid env-infra mappings       | `custom_2` output |

## Deployment Condition
Deployment occurs **only when the environment-infrastructure pair exists in** `valid_combinations`.

```yaml
when:
  pipelineStatus: Success
  condition: <+pipeline.variables.valid_combinations>.contains("<+matrix.env_names>:<+matrix.infra_names>")
```
## Execution Flow

- Stage 1: Generates environment names dynamically.
- Stage 2: Calls API to fetch corresponding infrastructures.
- Stage 3: Deploys ASG services based on valid environment-infrastructure pairs.

## API Used 

The pipeline calls the [Harness Infrastructure API](https://apidocs.harness.io/tag/Infrastructures#operation/getInfrastructureList) to fetch infra details

## Output Variables

- ENV_NAMES: Comma-separated environment names.
- INFRA_LIST: Comma-separated infrastructure identifiers.
- VALID_COMBINATIONS: Comma-separated valid environment-infra pairs.

## Conclusion
This pipeline streamlines ASG deployments by dynamically mapping environments to infrastructure using API-driven automation, ensuring efficient and error-free deployments.

