# Azure Function Deployment Pipeline

## Pipeline Overview
This pipeline is designed for the following use case:

1. Deploy an Azure Function application to Azure.
2. Use deployment slots to manage seamless rollouts and testing.
3. Provide rollback mechanisms to ensure application stability in case of deployment failures.

## Key Files and Their Purpose


- [**`harness-cd-pipeline/pipeline.yaml`**](/azure-function-deployment/harness-cd-pipelines/pipeline.yaml): Harness pipeline YAML for Azure Function deployment.
- [**`/harness-cd-pipeline/service.yaml`**](./harness-cd-pipelines/service.yaml): Harness service definition YAML for Azure Functions.
- [**`/harness-cd-pipeline/environment.yaml`**](./harness-cd-pipelines/environment.yaml): YAML defining the deployment environment in Harness.
- [**`harnesscd-pipeline/infrastructureDefinition.yaml`**](./harness-cd-pipelines/infrastructureDefinition.yaml): YAML defining the infrastructure for the deployment.
---


## Pipeline Use Case Details

**Stage 1: AzureFunctionDeploy**

**Objective**: Deploy an artifact to Azure deployment of Azure Functions, enabling you to automate and manage serverless function deployments to Azure with ease.

**Inputs**:

- [**Connector Reference**](#creating-azure-connector): Specify the connector for Azure authentication.
- [**Function App**](#creating-function-app): Provide the name of the Azure Function App.
- [**Deployment Slot**](#creating-deployment-slots): Specify the deployment slot.
- **Resource Group**: Provide the Azure resource group for the deployment.
- **Subscription ID**: Specify the Azure subscription ID.
- [**Artifact Source**](https://developer.harness.io/docs/continuous-delivery/x-platform-cd-features/services/artifact-sources/): Specify your artifact source
- **Container Image**: Provide the [container image](https://learn.microsoft.com/en-us/azure/azure-functions/functions-how-to-custom-container?tabs=core-tools%2Cacr%2Cazure-cli2%2Cazure-cli&pivots=azure-functions) that contains azure function to deploy.
- - **Kubernetes cluster for containerised step group**: Select the kubernetes cluster for container based execution for step group for Azure Function Step Group for Deploy and Rollback step.

### Creating Azure Connector 

Refer to [Add Microsoft Azure Connector](https://developer.harness.io/docs/platform/connectors/cloud-providers/add-a-microsoft-azure-connector/#add-an-azure-connector)

### Creating Function App

- In the search bar, type **Function Apps** and select **Create**.

- Fill in the details:
  - **Subscription**: Select your Azure subscription.
  - **Resource Group**: Select the one created earlier.
  - **Function App Name**: Enter a unique name.
  - **Region**: Select your region.
  - **Runtime Stack**: Select the runtime (e.g., Node.js, Python).
  - **Storage Account**: Select the storage account.
  - Click **Review + Create → Create**.

  ![](./static/Screenshot%202024-12-03%20at%202.53.05%20PM.png)

  You can use Azure CLI as well to create Function App, Resource Group and Storage Account.

Read more on [Azure Documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-get-started?pivots=programming-language-python).

### Creating Deployment Slots

1. Navigate to **Function App**

2. In the Azure Portal, go to **Function Apps** and select your function app.

3. Add a **Deployment Slot**:

Under the Deployment section in the left-hand menu, click **Deployment Slots → Add Slot**.

Fill in the details:
  - Name: Enter a **slot name** (e.g., staging).
  - Clone Settings: Select whether to clone settings from the production slot.
  - Click **Add**.

Once created, you'll see the new slot listed under **Deployment Slots**.

![](./static/Screenshot%202024-12-03%20at%203.31.06%20PM.png)

## Execution 

When deploying an Azure Function using Harness, the Function App and Deployment Slots are automatically fetched based on the Azure connector provided in the Azure Function Deploy step.

The Function App must exist in the same subscription as specified in the Azure connector.

If a Function App or Deployment Slot does not exist, create them in the Azure Portal following the instructions:-

1. [Creating Function App](#creating-function-app)
2. [Creating Deployment Slots](#creating-deployment-slots)

## Conclusion 

This Azure Function deployment pipeline streamlines the process of deploying serverless applications to Azure. By leveraging deployment slots, the pipeline ensures zero-downtime rollouts and testing, with rollback mechanisms for added reliability.

For further details on setting up this pipeline, refer to the [Harness documentation](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/azure/azure-function-tutorial/).


 



