# Google Cloud Run Deployment Pipeline

## Pipeline Overview

This pipeline is designed for the following use case:

1. Deploy an application to Google Cloud Run.
2. Shift traffic between revisions to ensure a seamless user experience.
3. Provide rollback mechanisms in case of deployment failures.

---

## Key Files and Their Purpose


- [**`harness-cd-pipeline/pipeline.yaml`**](/google-cloud-run/harness-cd-pipeline/pipeline.yaml): Harness pipeline YAML for Google Cloud Run deployment.
- [**`/harness-cd-pipeline/service.yaml`**](./harness-cd-pipeline/service.yaml): Harness service definition YAML.
- [**`/harness-cd-pipeline/environment.yaml`**](./harness-cd-pipeline/environment.yaml): YAML defining the deployment environment in Harness.
- [**`harnesscd-pipeline/infrastructureDefinition.yaml`**](./harness-cd-pipeline/infrastructureDefinition.yaml): YAML defining the infrastructure for the deployment.
- [**`harness-cd-pipeline/manifest.yaml`**](./harness-cd-pipeline/manifest.yaml): Manifest file required for defining the Google Cloud Run service.
---

## Pipeline Use Case Details

**Stage 1: Deployment**

**Objective**: Deploy an artifact to Google Cloud Run using Harness.

**Inputs**:

- **Image Path**: Provide the Image path of your artifact.
- **Artifact tag**: Provide artifact tag that you want to deploy using google cloud run.
- **Kubernetes cluster for containerised step group**: Select the kubernetes cluster for container based execution for step group for Google Cloud Run Step Group and Google Cloud Run Rollback Step Group.
- **Container Registry and Image**: Select Container registry and Image for Google cloud Run Deploy, Google Cloud Run Prepare Rollback Data, GoogleCloudRunTrafficShift_1.

Google Cloud Run Manifest File Structure
The manifest file defines the Google Cloud Run service :-

```yaml
# Following are the minimum set of parameters required to create a Google Cloud Run Service.
# Please make sure your uploaded manifest file includes all of them.

apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: qademo3
  annotations:
    run.googleapis.com/minScale: '2'
spec:
  template:
    spec:
      containers:
        - image: <+input>
          ports:
            - containerPort: 8080
```
---

## Documentation

- [Google Cloud Run](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/google-cloud-functions/google-cloud-run/)
- [CD Artifact Source](https://developer.harness.io/docs/continuous-delivery/x-platform-cd-features/services/artifact-sources/)

## Conclusion

This Google Cloud Run deployment pipeline is designed to streamline the process of deploying and managing applications on Google Cloud Run. By leveraging Harness, it ensures seamless traffic shifting between revisions, robust rollback mechanisms, and a smooth user experience. The provided YAML configurations simplify the setup of essential components like services, environments, infrastructure, and manifests, enabling a structured and efficient deployment process.

For further details on setting up this pipeline, refer to the [Harness documentation](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/google-cloud-functions/google-cloud-run/).



