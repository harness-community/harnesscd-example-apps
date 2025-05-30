## ECS Blue-Green Traffic Shifting Pipeline

**Prerequisites:**
- An existing ECS **Service** (`<SERVICE_REF>`) configured in your AWS account.
- A corresponding ECS **Environment** (`<ENVIRONMENT_REF>`) defined in Harness with infrastructure definition `<INFRA_DEF>`.

This pipeline implements a blue-green deployment for an ECS service, followed by staged traffic shifting with manual approvals and rollback capabilities. It uses a matrix strategy to shift traffic in increments, first to the staging target group, then to full production.

---

### Metadata (Generic)

- **Identifier & Name:** `<PIPELINE_ID>` / `<PIPELINE_NAME>`  
- **Project:** `<PROJECT_ID>`  
- **Organization:** `<ORG_ID>`  
- **Deployment Type:** ECS  

---

### Stage: `<STAGE_NAME>`

1. **Deployment Configuration**  
   - **Service:** `<SERVICE_REF>`  
   - **Environment:** `<ENVIRONMENT_REF>`  
   - **Infrastructure:** `<INFRA_DEF>`  

2. **Execution**  
   The execution block contains three step groups and rollback logic:

   #### a. Blue-Green Create Service
   - Creates both blue and green ECS services behind the load balancer.  
   - Uses variables for listener, rules, and target groups.  
   - `isTrafficShift: true` registers the green service without shifting traffic immediately.  

   #### b. Stage Traffic Shifting
   - **Strategy:** Matrix weights (e.g., 50, 100) with `maxConcurrency: 1`.  
   - **Harness Approval:** Manual gate.  
   - **Traffic Shift (Standalone):** Shifts `<+matrix.weight>%` to staging target group and `<+(100 - <+matrix.weight>)>%` remains on production.

   #### c. Production Traffic Shifting
   - **Strategy:** Same matrix.  
   - **Harness Approval:** Manual gate.  
   - **Traffic Shift (Inherit):** Applies `<+matrix.weight>%` to green service; the remainder to production.

3. **Rollback Steps**  
   - **EcsBlueGreenRollback:** Reverts service deployments.  
   - **StandAloneTrafficShiftRollback:** Reverts any staged traffic changes.  

---

### Variables (Placeholders)

| Name               | Type   | Description                                            | Example Placeholder       |
|--------------------|--------|--------------------------------------------------------|---------------------------|
| `listener`         | String | ALB listener ARN                                       | `<LISTENER_ARN>`          |
| `prodRule`         | String | Production listener rule ARN                           | `<PROD_RULE_ARN>`         |
| `devRule`          | String | Staging listener rule ARN                              | `<STAGE_RULE_ARN>`        |
| `prodTargetGroup`  | String | Production target group ARN                            | `<PROD_TG_ARN>`           |
| `stageTargetGroup` | String | Staging target group ARN                               | `<STAGE_TG_ARN>`          |
| `matrix.weight`    | Number | Traffic percentage from matrix strategy                | `50` or `100`             |

---

**Flow Summary**:  
1. **Initialize:** Deploy blue & green services.  
2. **Stage Shift:** Incremental traffic shift with approvals.  
3. **Prod Shift:** Final traffic allocation with approvals.  
4. **Rollback:** Revert services and traffic on failure.