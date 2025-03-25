# Dynamic Terraform Workspace Creation Step Template

## Overview

This step template helps you automatically create a Terraform workspace in Terraform Cloud (or Enterprise) if it does not already exist. It simplifies your infrastructure provisioning workflow by ensuring required resources are created dynamically.

## Use Case Solved

- You're using Terraform Cloud (TFC) or Terraform Enterprise (TFE) for managing your infrastructure state.
- You want to dynamically select or create Terraform workspaces based on a given prefix and dynamic suffix.

## What This Template Does

- Checks if the specified Terraform workspace (constructed from a prefix and dynamic suffix) exists.
    - If the workspace doesn't exist, it automatically creates it using the Terraform Cloud API.
- Outputs the Terraform workspace name as an output variable, allowing it to be referenced in subsequent pipeline steps.

## How to Use

1. Add this step template to your Harness pipeline.
2. Set pipeline variables for workspace suffix, workspace prefix and org_name dynamically during pipeline execution.
3. Reference the generated workspace name output variable in subsequent steps for consistent resource deployments.

## Requirements

- Terraform Cloud or Terraform Enterprise account and API token.

- Harness secret setup with the Terraform Cloud API token.

## Example Scenario

If your workspace prefix is mypref- and the dynamic suffix is dev, this template:
- Creates a Terraform workspace named `mypref-dev` (if not already existing).

This automation ensures your workspace is ready for subsequent infrastructure provisioning steps.