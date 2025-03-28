# K8s Diff Step

This example demonstrates how to use the `kubectl diff` command using Harness’ **K8s Diff** step. By adding this step in the pipeline, you can compare the current live state of deployed Kubernetes resources with changes defined in a YAML file.

## Prerequisites

You would need this initial setup to run your Kubernetes pipeline:

- **Github connector**: Here is the [Github-connector YAML](/deploy-own-app/cd-pipeline/github-connector.yml) for reference.
- **Kubernetes connector**: Here is the [Kubernetes-connector YAML](/deploy-own-app/cd-pipeline/kubernetes-connector.yml) for reference.
- **Service**: Here is the [Service YAML](/deploy-own-app/cd-pipeline/service.yml) for reference.
- **Environment**: Here is the [Environment YAML](/deploy-own-app/cd-pipeline/environment.yml) for reference.
- **Infrastructure**: Here is the [Infrastructure YAML](/deploy-own-app/cd-pipeline/infrastructure-definition.yml) for reference.

You must have the **diffutils** package installed on your system to use the `kubectl diff` command. This package provides the necessary utilities for comparing file differences.

## Pipeline Overview

- [**`harness-cd-pipeline/pipeline.yaml`**](pipeline.yaml): Harness pipeline YAML for the **K8s Diff** step.

## Workflow Explanation

The pipeline has a stage with the following configuration:

   - **Deployment Type**: Kubernetes  
   - **Service**: References a Harness Kubernetes Service (`k8s_service`) which should contain or reference your Kubernetes manifests.  
   - **Environment**: Points to the `samplepipeline` environment, using an infrastructure definition (`k8sinfra`) that connects to the target Kubernetes cluster.

The stage has two steps:

**Step-1**: **K8s Diff Step**  
This step fetches the difference between the current live state of deployed Kubernetes resources with changes defined in a YAML file and the upcoming YAML configured in the YAML.

**Step-2**: **K8s Rolling Deployment**  
This step performs a rolling deployment of the service.

## Conclusion

This pipeline configuration shows how to set up a **K8s Diff step** in Harness.
