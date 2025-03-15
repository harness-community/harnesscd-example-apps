# Multi-Environment Deployment Using Environment Groups

This pipeline demonstrates how to deploy to different Environment Groups within the same execution.

In this example:

- Pipeline chaining is used in the first three stages.
- In the fourth stage, a stage template is used with a fixed environment group. This stage allows you to select specific environments within the environment group for deployment.

Files in This Folder:
1. [pipeline.yaml](/custom-usecases/Dynamic-deployment-for-Multi-env-usecase-2/pipeline.yaml):  Contains the pipeline YAML.
2. [chained-pipeline.yaml](/custom-usecases/Dynamic-deployment-for-Multi-env-usecase-2/chained-pipeline.yaml): The pipeline triggered from the first three stages of the main pipeline.
3. [stage-template.yaml](/custom-usecases/Dynamic-deployment-for-Multi-env-usecase-2/stage-template.yaml): Holds the stage template YAML. Here, the Environment Group is fixed, but users can select specific environments within the group.
