# Approval Handling Repeat Loop Pipeline

## Overview
This pipeline automates **approval handling** using **Harness CI/CD**, allowing multiple approval loops with conditional execution based on approval or rejection.

## Features
- **Traffic Shifting Execution:** Handles traffic shifting before approval.
- **Harness Approval Step:** Requests user approval via the **HarnessApproval** step.
- **Conditional Execution:** Executes different steps based on approval or rejection.
- **Repeat Strategy:** Supports multiple approval loops with **1st, 2nd, and 3rd approval cycles**.

## Pipeline Flow

### **Stage: s2**
#### **Step 1: Traffic Shifting Execution**
- Runs **ShellScript_3** to indicate traffic shifting completion.

#### **Step 2: Approval Handling with Repeat Loop**
- Executes a **step group** (`HarnessApprovalRepeat`) that handles multiple approval cycles.

  - **HarnessApproval_2:** Requests manual approval from **callback_test_user**.
  - **ShellScript_1:** Executes if approval **succeeds** (`SUCCEEDED`).
  - **ShellScript_4:** Executes if approval **is rejected** (`APPROVAL_REJECTED`).

#### **Step 3: Repeat Strategy**
- The **repeat strategy** allows three approval cycles:
  - **1st Approval**
  - **2nd Approval**
  - **3rd Approval**
- If an approval is rejected, rollback actions can be triggered.

## Conditional Execution
- If **approved**, `ShellScript_1` executes (`echo hello`).
- If **rejected**, `ShellScript_4` executes (`echo "traffic shifting rollback"`).

## Strategy: Repeat Handling
- Uses **repeat strategy** with `maxConcurrency: 1`, ensuring **sequential approval handling**.
- Skips queued executions on failure (`onFailure: SkipQueued`).

## Conclusion
This pipeline provides **repeatable and conditional approval handling** in a controlled manner, ensuring smooth deployment progress while maintaining rollback capabilities when required.
