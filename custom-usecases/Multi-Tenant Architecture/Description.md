## Purpose of the Pipeline

This pipeline demonstrates a multi-tenant deployment strategy using Harness, with the ability to:

1. Fetch code from a Git repository.
2. Process tenant configurations for different environments and infrastructures dynamically.
3. Generate URLs for tenants based on their configuration.
4. Deploy applications using a matrix strategy for multiple tenants, environments, and infrastructures.

## Pipeline Stages Overview

1. **Stage: fetch_code (CI Stage)**

 - Purpose:
    - Fetch code from the specified Git branch and process tenant configurations.
 - Key Steps:
    1. GitClone: Pulls the repository from vishal_gitSample using branch test_01.
    2. Run Step (Python Script):

        - Processes the master configuration XML (master_config.xml) and tenant-specific files (tenant_config directory).
        - Generates a list of valid environment and infrastructure combinations.
        - Outputs variables:
            - environment: Comma-separated list of environment names.
            - infrastructure: Comma-separated list of infrastructure names.
            - VALID_COMBINATIONS: A formatted string with valid combinations (e.g., env.infra).

    3. Run Step (Explicit Tenant URLs):

    - Extracts tenant-specific IPs from the tenant_ip_config.xml.
    - Explicitly generates tenant URLs for each tenant and stores them as output variables.
    - These output variables (`TENANT_1_URL`, `TENANT_2_URL`, `TENANT_3_URL`) can be accessed in subsequent steps **within the same pipeline execution**.

        
2. **Stage: s1 (Deployment Stage)**

    - Purpose:
        - Deploy applications to Kubernetes environments for each valid combination of environment and infrastructure.
    - Key Features:
        - Uses a matrix strategy to iterate over combinations of:
            - env: Dynamically derived environment list.
            - infra: Dynamically derived infrastructure list.
        - Executes only for valid combinations using:
        `<+pipeline.variables.VALID_COMBINATIONS>.contains("<+matrix.env>.<+matrix.infra>")`

3. **Additional Stage (Optional):**
    - Can be added to perform post-deployment checks or validations.

**Key Variables**

- Pipeline Variables:

    - TENANT_PROJECT: Input for tenant IDs (e.g., tenant_1,tenant_2).
    - ENV_NAME: Input for environments (e.g., prod,stage).
    - COMPONENT: Input for components (e.g., Macrims,Decisions).
    - env_list: Dynamically populated list of environments.
    - infra_list: Dynamically populated list of infrastructures.
    - VALID_COMBINATIONS: Dynamically generated list of valid env.infra pairs.

- Output Variables:

    - TENANT_1_URL, TENANT_2_URL, TENANT_3_URL: Explicit URLs generated for each tenant.

## Note

**Configuration Changes**

- Modify the Configuration Files:
    - Update tenant_project_X.xml and tenant_ip_config.xml to reflect your specific environments, infrastructures, and tenant IP details.

- Modifications Needed in pipeline.yaml:

    1. Project and Organization Settings:

        - Update projectIdentifier and orgIdentifier to match your project and organization in Harness.
        
    2. Connector References:

    - GitHub Connector: Update connectorRef: GitHub_connector to point to the connector configured for the Git repository where your configuration files (master_config.xml, tenant_project_X.xml, and tenant_ip_config.xml) are stored.
    - Docker Connector: Update connectorRef: Docker_connector to point to the Docker connector configured to fetch container images for the Run steps.
    
    3. Paths for Configuration Files:

        - In the Run step:
            - Update MASTER_CONFIG to the correct path of your master configuration file (e.g., test-app/master_config.xml).
            - Update TENANT_FILES_DIR to the directory where your tenant configuration files (tenant_project_X.xml) are stored.

        - In the Run_2 step:
            - Update TENANT_CONFIG_FILE to the path where your tenant IP configuration file (tenant_ip_config.xml) is stored.