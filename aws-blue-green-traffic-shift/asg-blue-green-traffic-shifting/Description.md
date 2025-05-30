## ASG Blue-Green Traffic Shifting Pipeline

**Prerequisites:**
- An existing Auto Scaling Group service (**your_service_ref**) backed by an AMI artifact.
- A Harness **Environment** (**your_environment_ref**) with an ASG infrastructure definition (**your_infra_def**).
- Application Load Balancer and listener rules preconfigured for your ASG.

---

### Overview

This pipeline performs a blue-green deployment for AWS Auto Scaling Groups, incrementally shifting traffic from the blue ASG to the green ASG. The process includes:

1. **Blue-Green Deployment** – create green ASG alongside blue ASG.  
2. **Traffic Shifting** – staged weight-based traffic shifts.  
3. **Downsize & Cleanup** – optional teardown of old ASG instances.  
4. **Rollback** – automatic reversion on failure.

---

### 1. Blue-Green Deployment

- **Step Group:** `blueGreenDeployment`  
- **Step:** `AsgBlueGreenDeploy`  
  - **Purpose:** Launches a new green ASG using the specified AMI artifact, matching the configuration of the existing blue ASG.  
  - **Key Spec Parameters:**  
    - `instances`: Defines min, max, and desired instance counts to ensure consistent capacity.  
    - `loadBalancers`: Specifies the load balancer name, production listener ARN, and listener rule ARN.

---

### 2. Staged Traffic Shifting

- **Step:** `AsgShiftTraffic30`  
  - **Type:** `AsgShiftTraffic`  
  - **Purpose:** Shifts 30% of incoming traffic to the green ASG while retaining the blue ASG at 70%.  
  - **Downsize Behavior:** `downsizeOldAsg: false` keeps blue ASG instances active for rollback or gradual teardown.

- **Step:** `AsgShiftTraffic100`  
  - **Type:** `AsgShiftTraffic`  
  - **Purpose:** Completes the cutover by shifting 100% of traffic to the green ASG.  
  - **Downsize Behavior:** `downsizeOldAsg: true` scales down the blue ASG after full traffic shift.

---

### 3. Rollback Steps

- **Step:** `AsgBlueGreenRollback`  
  - **Type:** `AsgBlueGreenRollback`  
  - **Purpose:** On failure of any step, reverts to the original blue ASG configuration and traffic distribution.

---

### Flow Summary

1. **Initialize:** Deploy green ASG in parallel with blue ASG.  
2. **Partial Cutover:** Shifts a defined percentage (e.g., 30%) to green ASG.  
3. **Full Cutover:** Shifts all traffic (100%) to green ASG and optionally downsizes the blue ASG.  
4. **Rollback:** If any step fails, instantly revert to the original ASG setup and traffic routing.

---

### Variables (Placeholders)

| Placeholder            | Description                                   |
|------------------------|-----------------------------------------------|
| `your_service_ref`     | Harness reference for the ASG service         |
| `your_environment_ref` | Harness environment identifier                |
| `your_infra_def`       | Infrastructure definition for ASG             |
| `your_listener_arn`    | ARN of the ALB listener                       |
| `your_rule_arn`        | ARN of the ALB listener rule                  |
| `your_ami_artifact`    | Artifact reference for the AMI image          |
| `30`                   | First traffic shift percentage                |
| `100`                  | Final traffic shift percentage                |