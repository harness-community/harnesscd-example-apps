# Harness Pipeline Template for ADK Agent Deployment to AWS AgentCore

Pipeline template for deploying ADK agents to **Amazon Bedrock AgentCore Runtime** via direct code zip deployment.

**Template: `aws-agentcore-s3-codezip-deploy.yaml`** — Single CI stage that clones the agent source, validates the AgentCore contract, cross-installs arm64 dependencies, packages a zip, uploads it to S3, creates or updates the AgentCore runtime, and runs a smoke invoke.

### Agent project requirements

- Entrypoint at the top of the agent directory (default `main.py`)
- `pyproject.toml` or `requirements.txt` (dependencies are baked into the zip; AgentCore does not install them)
- Runtime contract: `@app.entrypoint` from `bedrock-agentcore`, or `POST /invocations` + `GET /ping` on port `8080`

