## Spot Elastigroup Blue-Green Traffic Shifting Pipeline

**Prerequisites:**
- A Spot Elastigroup **Service** (your_service_ref) already defined in AWS.
- A Harness **Environment** (your_environment_ref) configured with infrastructure definition `your_infra_def`.
- AWS connector (e.g., `your_connector_ref`) with permissions to manage Elastigroups and load balancers.
- Target groups and listener rules set up in your Application Load Balancer.

---

### Overview

This pipeline orchestrates a blue-green deployment on Spot Elastigroup, gradually shifting traffic from the existing (blue) group to a new (green) group. It consists of:

1. **Stage Setup** – provision blue/green Elastigroups.  
2. **Optional Scripts** – custom logic before swapping.  
3. **Staged Traffic Shifting** – incremental weight-based shifts with approval.  
4. **Production Traffic Shifting** – final traffic cutover.  
5. **Post-Swap Scripts** – optional cleanup.  
6. **Rollback** – automatic reversion on failure.

---

### 1. Stage Setup

- **Step:** `ElastigroupBGStageSetup`  
- **Purpose:** Creates a new green Elastigroup alongside your existing blue group.  
- **Key Spec Parameters:**  
  - `instances`: Desired, minimum, and maximum counts ensure proper capacity.  
  - `connectedCloudProvider`: AWS region and connector reference.  
  - `loadBalancers`: Configures ALB listener port, listener rule ARN, and initial `isTrafficShift: true` so green group registers without receiving traffic.  

---

### 2. Pre-Swap Script

- **Step:** `ShellScript` (Before Swap)  
- **Purpose:** Execute any custom commands (e.g., smoke tests, data migrations) before traffic shifting begins.  
- **Configuration:** Inline Bash script passed via pipeline input.

---

### 3. Stage Traffic Shifting

- **Step Group:** Stage Environment Traffic Shifting  
- **Strategy:** Matrix with `weight` values (e.g., 50, 100) and `maxConcurrency: 1` to control the percentage of traffic shifted per iteration.  
- **Steps:**  
  1. **Harness Approval:** Manual gate to review metrics/logs before shifting.  
  2. **ElastigroupBlueGreenTrafficShift (Standalone)**  
     - **forwardTrafficConfig:**  
       - `targetGroupArn: your_stage_tg_arn`, weight `<+matrix.weight>%`  
       - `targetGroupArn: your_prod_tg_arn`, weight `100 - <+matrix.weight>%`  
     - **Behavior:** Distributes traffic according to the matrix weight, without inheriting previous configuration.

---

### 4. Pre-Inherit Script

- **Step:** `ShellScript` (Before Inherit)  
- **Purpose:** Additional custom logic before production traffic cutover (optional).

---

### 5. Production Traffic Shifting

- **Step Group:** Prod Environment Traffic Shifting  
- **Strategy:** Same matrix strategy (e.g., 50, 100).  
- **Steps:**  
  1. **Harness Approval:** Final human approval for production cut.  
  2. **ElastigroupBlueGreenTrafficShift (Inherit)**  
     - **weightPercentage:** `<+matrix.weight>%`  
     - **Behavior:** Inherits ALB and target group configuration from the setup step, shifting final traffic percentages.

---

### 6. Post-Swap Script

- **Step:** `ShellScript` (Post Swap)  
- **Purpose:** Run cleanup tasks or notifications after traffic cutover.

---

### 7. Rollback Steps

- **ElastigroupRollback:** Reverts both blue and green Elastigroup configurations to the original state.  
- **StandAloneTrafficShiftRollback:** Undoes any partial traffic shifts for staged or production phases.

---

### Flow Summary

1. **Initialize:** Set up blue & green groups.  
2. **Validate & Approve:** Gate via scripts and approvals.  
3. **Stage Shift:** Gradual traffic migration to green in staging.  
4. **Production Cutover:** Final traffic shift in production.  
5. **Cleanup:** Scripts and health checks.  
6. **Rollback (if needed):** Automatic revert on errors.

---

### Variables (Placeholders)

| Name                 | Description                                    |
|----------------------|------------------------------------------------|
| `your_service_ref`   | Elasticgroup service identifier                |
| `your_environment_ref` | Harness environment identifier               |
| `your_infra_def`     | Infrastructure definition identifier           |
| `your_connector_ref` | AWS connector reference                        |
| `your_region`        | AWS region (e.g., us-east-1)                   |
| `your_load_balancer_name` | ALB name                               |
| `your_stage_tg_arn`  | ARN of staging target group                    |
| `your_prod_tg_arn`   | ARN of production target group                 |
| `<+matrix.weight>`   | Percentage of traffic to shift (50, 100, etc.) |
