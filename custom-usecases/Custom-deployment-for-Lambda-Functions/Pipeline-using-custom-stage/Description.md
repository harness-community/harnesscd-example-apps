# Deploy AWS Lambda Function Using Custom Stage

In this example, let's understand how to deploy a Lambda using a custom stage.

## Pipeline Overview

The pipeline consists of a custom stage with a container step that deploys a Lambda function.

**Key Takeaways:**
1. The artifact source used here is AWS S3.
2. The artifact size can be of any size.
3. The script will check if the function exists in Lambda and updates it if it exists or creates a new function.
4. It deploys the Lambda function.

## Configuring Container Step

- **Name:**  
  Name for the Container step.

- **Timeout:**  
  How long you want Harness to try to complete the step before failing and initiating the stage or step failure strategy.

- **Container Registry:**  
  We use the Docker connector.

- **Image:**  
  Here we use the AWS CLI provided by Amazon:  
  `amazon/aws-cli:2.24.5`  
  This is a public image officially provided by AWS.

- **Command:**  
  In the command, you provide the shell script to fetch the artifact from the S3 bucket and deploy it.

**Infrastructure Settings**

- **Connector:**  
  Provide the Harness connector to connect to the cluster.

- **Namespace:**  
  The namespace in the cluster where you want to run the step.

The connector for this case can be an AWS connector connecting the EC2 or EKS cluster, or any Kubernetes cluster, as we provide the credentials required in the script.

Here is the [pipeline.yaml](/custom-usecases/Custom-deployment-for-Lambda-Functions/Pipeline-using-custom-stage/pipeline.yaml) file for a working sample.
