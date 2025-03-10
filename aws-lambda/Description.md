# AWS Lambda Deployment Pipeline Sample

## Overview

This sample pipeline demonstrates how to deploy an **AWS Lambda function** using **Harness Continuous Delivery**. 

It supports deploying **both ZIP-based artifacts** (stored in **Amazon S3**) and **container images** (hosted in **Amazon ECR**). Additionally, it allows configuring **runtime settings**, **IAM roles**, and **environment variables** required for Lambda execution.

This pipeline specifically demonstrates **deploying a Lambda function stored as a ZIP file in an S3 bucket** and referencing it in the **Service** step.


## Prerequisites

Before using this pipeline, ensure you have:

- An **S3 bucket** to store the Lambda ZIP file or an **ECR repository** for container-based deployments.
- An **IAM role** with permissions to invoke and update Lambda functions.


## Key Files and Their Purpose

- [**`harness-cd-pipeline/pipeline.yaml`**](./harnesscd-pipeline/pipeline.yml): Harness pipeline YAML for AWS Lambda deployment.
- [**`harness-cd-pipeline/service.yaml`**](./harnesscd-pipeline/service.yml): Service definition YAML for AWS Lambda functions.
- [**`harness-cd-pipeline/environment.yaml`**](./harnesscd-pipeline/environment.yml): Defines the deployment environment in Harness.
- [**`harness-cd-pipeline/infrastructureDefinition.yaml`**](./harnesscd-pipeline/infrastructure-definition.yml): Defines the infrastructure for the deployment.
- [**`harness-cd-pipeline/aws-connector.yaml`**](./harnesscd-pipeline/aws-connector.yml): Defines the AWS connector for the deployment.


## Before You Run the Pipeline

1. **Store the Lambda function code** in an S3 bucket in **ZIP format**.  
   A sample AWS function is provided for reference:  
   [**Sample Function**](./hello_world.zip)

2. Store the [**Lambda Function Definition**](./function-definition.json) in the **Harness File Store**.

---

## Pipeline Workflow

### **1. Service Step**
- Fetches the **Lambda function definition** stored in the **Harness File Store**.
- Fetches the **Lambda function package** from **Amazon S3**.

### **2. Environment Step**
- Validates the environment.
- Validates the **infrastructure definitions**.

### **3. Deployment Step**
- Deploys the Lambda function.
- Invokes the Lambda function to verify deployment.

### **4. Rollback Strategy**
- Rollback in case of deployment failure.

---

## Additional Resources

For detailed guidance on AWS Lambda deployments in Harness, refer to:  
[Harness AWS Lambda Deployments Documentation](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/aws/aws-lambda-deployments)
