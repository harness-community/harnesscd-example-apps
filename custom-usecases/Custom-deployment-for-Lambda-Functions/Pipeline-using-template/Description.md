# Deploy AWS Lambda Function Using Deployment Template

In this example, we demonstrate how to deploy a Lambda function using a deployment template that encapsulates the container step configuration.

## Deployment Template Overview

The Deployment Template consists of a container step that can be used to run Lambda functions.

### Configuring a Deployment Template

1. **Navigate to Project Settings:**  
   Click on **+New Template** and select **Deployment**.

2. **Provide the Template Details:**  
   - **Name:** Enter a descriptive name for the template.
   - **Version Label:** Provide a version label.
   - Click on **Start**.

3. **Configure Infrastructure Tab:**  
   - Switch from **Visual** to **YAML** view.
   - Paste the contents from [`infrastructure.yaml`](/custom-usecases/Custom-deployment-for-Lambda-Functions/Pipeline-using-template/infrastructure.yaml).
   - Save the YAML.

4. **Switch to Visual View and Configure Execution Tab:**  
   - Navigate to the **Execution** tab.
   - Under **Deployment Steps**, click on **+Add Step**.
   - Click on **Create and use template**, then select **Container Step** from the step library.

### Configuring the Container Step in the Deployment Template

- **Name:**  
  A descriptive name for the container step within the deployment template.

- **Timeout:**  
  Specifies how long Harness should attempt to complete the step before failing and triggering the stage or step failure strategy.

- **Container Registry:**  
  Utilizes the Docker connector.

- **Image:**  
  Uses the AWS CLI image provided by Amazon:  
  `amazon/aws-cli:2.24.5`  
  This public image is officially provided by AWS.

- **Command:**  
  The command field includes the shell script to fetch the artifact from an S3 bucket and deploy the Lambda function.  
  Here is the [command.sh](/custom-usecases/Custom-deployment-for-Lambda-Functions/Pipeline-using-template/command.sh) for reference.

### Infrastructure Settings in the Deployment Template

- **Connector:**  
  Specifies the Harness connector that links to the target cluster.

- **Namespace:**  
  Indicates the namespace in the cluster where the container step will execute.

The connector can be an AWS connector configured for EC2, EKS, or any Kubernetes cluster, as the required credentials are provided within the script.

Save the step and template.

Here is [template.yaml](/custom-usecases/Custom-deployment-for-Lambda-Functions/Pipeline-using-template/template.yaml) for reference.

## Pipeline Overview

The pipeline uses a deployment template that contains a container step to deploy a Lambda function. This template is then referenced in a pipeline, ensuring consistency and reusability across deployments.

1. **Add Stage:**  
   In your pipeline, click on **Add Stage** and select **Deploy**.

2. **Select Deployment Template:**  
   Under **Deployment Templates**, select the template you created earlier.

3. **Provide Service and Environment Details:**  
   Although the container step in the template will not use these details (as the artifact source is directly provided in the shell script), you should still provide the service and environment details for context.

4. **Configure Execution Tab:**  
   - After the **Fetch Instances** step, click on **+Add Step**.
   - Click on **+Deployment Template Step** and select the template you created.

5. **Save and Run the Pipeline.**

Here is the [pipeline.yaml](/custom-usecases/Custom-deployment-for-Lambda-Functions/Pipeline-using-template/pipeline.yaml) file for a working sample that references this deployment template.
