# Vercel Progressive Delivery (Canary) — Harness Pipeline Guide

## Overview

This pipeline implements a **canary deployment strategy** for Vercel frontends by gradually shifting traffic from the current production deployment to a new deployment in controlled stages:

**10% → 25% → 50% → 75% → 100%**

Traffic routing is managed using **Vercel Edge Config**, enabling real-time percentage-based traffic splitting without requiring DNS changes.

---

## Prerequisites

Before running the pipeline, ensure the following secrets are configured in Harness:

| Secret Name | Description |
|---|---|
| `vercel_token` | Vercel API token with deployment permissions |
| `vercel_org_id` | Your Vercel Team/Organization ID |
| `vercel_project_id` | Your Vercel Project ID |

You must also configure:

- A **Vercel Edge Config** store
- Middleware that reads `traffic_config` and routes traffic accordingly

---

## Runtime Inputs

Provide the following inputs when triggering the pipeline:

| Input | Description |
|---|---|
| `Connector Ref` | Harness code connector pointing to your repository |
| `Repo Name` | Repository to build from |
| `Build` | Branch, tag, or PR to build |
| `edge_config_id` | Vercel Edge Config store ID |

---

## Pipeline Stages

```text
Build & Test
    ↓
Deploy New Version
    ↓
Canary-10
    ↓
Approve
    ↓
Canary-25
    ↓
Approve
    ↓
Canary-50
    ↓
Approve
    ↓
Canary-75
    ↓
Approve
    ↓
Full Cutover (100%)
```

---

## Stage Details

### 1. Build & Test

- Runs on `node:20-alpine`
- Installs dependencies
- Executes application tests

---

### 2. Deploy New Version

- Deploys the application to Vercel
- Creates a new production deployment
- Captures the generated deployment URL for downstream stages

---

### 3. Canary Stages

Stages:
- `Canary-10`
- `Canary-25`
- `Canary-50`
- `Canary-75`

Each stage:
- PATCHes the Vercel Edge Config
- Updates the traffic split JSON
- Gradually increases traffic to the new deployment

---

### 4. Approval Stages

Each canary stage is followed by a Harness approval gate.

#### Default Configuration

- Timeout: **2 hours**
- Approvers: `account._account_all_users`

#### Approval Outcomes

| Action | Result |
|---|---|
| Approve | Pipeline proceeds to next traffic percentage |
| Reject | Pipeline stops at current traffic split |

---

### 5. Full Cutover

The final stage:
- Routes **100%** of traffic to the new deployment
- Clears temporary traffic split configuration
- Completes the deployment rollout

---

## Edge Config Middleware (Required)

Your Vercel middleware must read `traffic_config` from Edge Config and dynamically route requests.

### Example Middleware

```javascript
// middleware.js

import { get } from '@vercel/edge-config';
import { NextResponse } from 'next/server';

export async function middleware(req) {
  const config = await get('traffic_config');

  if (!config) {
    return NextResponse.next();
  }

  const rand = Math.random() * 100;

  const target =
    rand < config.new_deployment.percentage
      ? config.new_deployment.url
      : config.current_deployment.url;

  return NextResponse.rewrite(
    new URL(req.url.replace(req.nextUrl.origin, target))
  );
}
```

---

## Rollback

### Option 1 — Reject Approval

Reject any approval stage to:
- Stop the pipeline
- Maintain the current traffic split

---

### Option 2 — Manual Rollback

Manually PATCH the Edge Config to restore:

```json
{
  "current_deployment": {
    "percentage": 100
  }
}
```

---

## Traffic Flow Example

| Stage | New Deployment Traffic | Current Production Traffic |
|---|---|---|
| Canary-10 | 10% | 90% |
| Canary-25 | 25% | 75% |
| Canary-50 | 50% | 50% |
| Canary-75 | 75% | 25% |
| Full Cutover | 100% | 0% |

---

## Summary

This pipeline enables safe, incremental frontend rollouts on Vercel using:
- Harness Pipelines
- Vercel Deployments
- Edge Config–based traffic routing
- Manual approval gates for progressive validation

The approach minimizes deployment risk while enabling rapid rollback and controlled production exposure.
