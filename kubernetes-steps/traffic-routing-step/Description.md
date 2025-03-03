# K8s Traffic Routing Step

This example demonstrates how to configure Kubernetes traffic shifting using Harness’ **K8s Traffic Routing** step with the **SMI** provider. By applying this pipeline, you can progressively route traffic between a stable service and a canary service on your Kubernetes cluster.

For more details on how Harness performs traffic shifting, see the official docs:  
[Harness Docs: Kubernetes Traffic Shifting Step](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/kubernetes/cd-k8s-ref/traffic-shifting-step)



## Prerequisites

1. **Kubernetes Cluster**: Ensure you have a functioning cluster and an appropriate Harness Infrastructure Definition referencing it.  
2. **SMI CRDs**: The [TrafficSplit CRD (`trafficsplits.split.smi-spec.io`)](https://github.com/servicemeshinterface/smi-sdk-go/tree/main/crds) must be installed, allowing your cluster to recognize SMI-based traffic splitting.  
3. **Service Mesh Implementation**: An SMI-compatible service mesh (e.g., [Open Service Mesh](https://openservicemesh.io/), [Linkerd with SMI plugin](https://github.com/linkerd/linkerd-smi)) that can act on `TrafficSplit` objects.  
4. **Kubernetes Services**:  
   - **Stable Service** (`example-stable-service`)  
   - **Canary Service** (`example-canary-service`)  



## Pipeline Overview

- [**`harness-cd-pipeline/pipeline.yaml`**](/kubernetes-steps/traffic-routing-step/pipeline.yaml): Harness pipeline YAML for the **K8s Traffic Routing** step.

### Key Fields

- **`Config Type`**:  
  - **`New Config`**: Select this option if you want to specify a new configuration for traffic routing in this step (e.g., in a Blue/Green or Canary deployment). This creates new resource(s).  
  - **`Inherit`**: Select this option to inherit a configuration from a previous step. This option patches existing resources.

- **`provider`**:  
  - **`smi`**: Instructs Harness to create or modify an **SMI-based** `TrafficSplit`.  
  - **`istio`**: Instructs Harness to create or modify an **Istio-based** routing rule.

- **`Resource Name`**: The name of the traffic configuration resource (applicable for `istio`).  
- **`rootService`**: `example-stable-service`: The primary (stable) service that users call.  
- **`Configure Routes`**:  
  - **`type: http`**: We’re defining an HTTP route.  
  - **`destinations`**: Weighted references to the stable and canary services:  
    - `host: example-canary-service`, `weight: 20`  
    - `host: example-stable-service`, `weight: 80`

![K8s Traffic Routing Step](/kubernetes-steps/static/k8s-traffic-routing.png)

Harness will translate these weights into a `TrafficSplit` object (`trafficsplits.split.smi-spec.io`), splitting traffic between the canary and stable services at a **20/80** ratio.



## Workflow Explanation

1. **Stage 1**  
   - **Deployment Type**: Kubernetes  
   - **Service**: References a Harness Kubernetes Service (`k8s_service`) which should contain or reference your Kubernetes manifests.  
   - **Environment**: Points to the `vishalsamplepipeline` environment, using an infrastructure definition (`vishalk8sinfra`) that connects to the target Kubernetes cluster.

2. **Execution Steps**  
   - **K8sTrafficRouting Step (type: config)**: Configures an SMI-based `TrafficSplit`.  
     - **Stable service** = `example-stable-service`  
     - **Canary service** = `example-canary-service` (20% of traffic)  
     - **Stable** retains 80%  

![K8s Traffic Routing Step Execution](/kubernetes-steps/static/k8s-traffic-routing-2.png)



## Verification and Troubleshooting

1. **View Execution Logs**: In Harness, monitor the pipeline execution logs. If the `TrafficSplit` CRD is missing, you’ll see an error.  
2. **Cluster Check**: Run `kubectl get trafficsplit -A` to confirm that a `TrafficSplit` object was created.  
3. **Traffic Testing**: If you have an external endpoint, test the stable vs. canary paths to ensure traffic distribution matches your weights.  
4. **Docs Reference**: For advanced configurations, weighted traffic adjustments, or additional steps, refer to the [Harness Documentation on the Kubernetes Traffic Shifting Step](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/kubernetes/cd-k8s-ref/traffic-shifting-step).



## Conclusion

This pipeline config shows how to set up **SMI-based** traffic routing in Harness. With the **K8sTrafficRouting** step configured for `provider: smi`, Harness manages a `TrafficSplit` resource under `trafficsplits.split.smi-spec.io`. By adjusting weights, you can progressively roll out canary deployments while still sending the bulk of traffic to your stable service.
