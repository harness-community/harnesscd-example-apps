# Helm Native Canary and Blue-Green Deployment Pipeline

## Pipeline Overview

This pipeline is designed for the following use case:
1. Build a Docker image and push it to a registry.
2. Perform Helm Native Canary deployment to a staging environment.
3. Swap the services to execute Blue-Green deployment for stable release.
4. Provide rollback mechanisms in case of deployment failures.

---

## Key Files and Their Purpose

- [**`Chart.yaml`**](/helm-native-canary-blue-green/Chart.yaml): Helm Chart configuration file defining the metadata for the application.
- [**`values.yaml`**](/helm-native-canary-blue-green/values.yaml): Configuration file containing default values for the Helm deployment.
- [**`templates/deployment.yaml`**](/helm-native-canary-blue-green/templates/deployment.yaml): Kubernetes Deployment template for managing pods.
- [**`templates/ingress.yaml`**](/helm-native-canary-blue-green/templates/ingress.yaml): Kubernetes Ingress template for routing external traffic.
- [**`templates/service.yaml`**](/helm-native-canary-blue-green/templates/service.yaml): Kubernetes Service template for exposing the application.
- [**`harnesscd-pipeline/Build_and_push_Dockerhub.yaml`**](/helm-native-canary-blue-green/harnesscd-pipeline/Build_and_push_Dockerhub.yaml)**: Harness pipeline YAML for building and pushing Docker images.
- [**`harnesscd-pipeline/pipeline.yaml`**](/helm-native-canary-blue-green/harnesscd-pipeline/pipeline.yaml): Harness pipeline YAML for Helm Native Canary Blue-Green deployments.
- [**`harnesscd-pipeline/helm_service_native.yaml`**](./harnesscd-pipeline/helm_service_native.yaml): Harness service definition YAML.
- [**`harnesscd-pipeline/environment.yamll`**](./harnesscd-pipeline/environment.yaml): YAML defining the deployment environment in Harness.
- [**`harnesscd-pipeline/infrastructureDefinition.yaml`**](./harnesscd-pipeline/infrastructureDefinition.yaml): YAML defining the infrastructure for the deployment.

---

## Pipeline Use Case Details

### Stage 1: Build
- **Objective**: Build a Docker image and push it to the Docker registry.
- **Inputs**:
  - Git repository and branch (`main`).
  - Docker image tag (`tag_value`).
- **Outputs**:
  - Captures and stores the image tag as `imagetag` as output variable as for use in subsequent stages.

### Stage 2: Deploy Stable
- **Objective**: Deploy the application using Helm Native Canary and Blue-Green deployment strategies.
- **Steps**:
  1. **Helm Canary Deployment**:
     - Deploys to a staging environment.
     - Uses Helm Blue-Green Canary strategies to ensure safe testing in production-like settings.
  2. **Service Swap**:
     - Swaps the staging service with the primary service to finalize the Blue-Green deployment.
- **Rollback**:
  - Rolls back the swap if any failures are encountered during the process.
- **Dynamic Tag Usage**:
  - Pulls the Docker image tag dynamically from the `Build` stage using `<+pipeline.stages.build.output.imagetag>`.

---

## Conclusion

This pipeline is ideal for applications requiring robust Helm Native deployment strategies, ensuring safe and dynamic Docker image delivery to production environments. The use of Canary and Blue-Green strategies minimizes risks during deployment, providing confidence in the release process.
