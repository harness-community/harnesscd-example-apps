# Git Clone Functionality for Run Step and Shell Script Step

## Purpose of the Pipeline

This pipeline demonstrates how to perform Git clone operations within Run steps and Shell Script steps in Harness pipelines, showcasing:

1. Manual Git repository cloning using authentication tokens
2. Accessing private repositories with secure token-based authentication
3. Navigating cloned repositories and performing file operations
4. Working with repositories when `cloneCodebase: false` is set
5. Compatibility with both Run steps and Shell Script steps
6. Flexibility to use in CI, CD, or Custom stages

## Pipeline Stages Overview

### Stage: s1 (CI Stage)

- **Purpose**: 
  - Demonstrates manual Git clone functionality within Run steps and Shell Script steps
  - Shows how to access and work with cloned repository contents
  - **Note**: This functionality can be implemented in CI, CD, or Custom stages

- **Key Features**:
  - `cloneCodebase: false` - Disables automatic codebase cloning
  - Caching enabled for improved performance
  - Build intelligence enabled for optimization
  - Cloud-based runtime execution
  - **Stage Flexibility**: Can be adapted for CI, CD, or Custom stage types

- **Key Steps**:

  1. **Run_1 (Run Step / Shell Script Step)**:
     - **Shell**: Sh (Bash shell execution)
     - **Step Type**: Compatible with both Run steps and Shell Script steps
     - **Command Operations**:
       - Performs Git clone using HTTPS with token authentication
       - Uses Harness secrets for secure token management
       - Navigates to the cloned repository directory
       - Reads and displays repository contents (README.md)

## Key Configuration Elements

- **Authentication**: 
  - Uses `<+secrets.getValue("your-git-token")>` for secure Git token retrieval
  - HTTPS-based Git clone with embedded authentication

- **Repository Access**:
  - Target repository: `https://github.com/your-org/your-repo.git`
  - Directory navigation: `cd cd-samples`
  - File operations: `cat README.md`

- **Platform Configuration**:
  - OS: Linux
  - Architecture: Amd64
  - Runtime: Cloud-based execution

## Use Cases

This pipeline is ideal for scenarios where:

- You need to clone multiple repositories in a single pipeline
- You want to clone repositories different from the pipeline's source repository
- You need to perform custom Git operations not available through standard codebase cloning
- You're working with private repositories requiring specific authentication methods
- You need to clone repositories conditionally based on pipeline logic
- You prefer using Shell Script steps over Run steps for Git operations

## Configuration Changes Required

### Pipeline File Location:
- **Pipeline Configuration**: `./pipeline.yaml`

### Modifications Needed in pipeline.yaml:

1. **Project and Organization Settings**:
   - Update `projectIdentifier: your-project` to match your Harness project
   - Update `orgIdentifier: default` to match your organization identifier

2. **Secret Configuration**:
   - Create a Harness secret named `your-git-token` containing your Git personal access token
   - Ensure the token has appropriate repository access permissions

3. **Repository Details**:
   - Replace `https://github.com/your-org/your-repo.git` with your actual repository URL
   - Update `cd cd-samples` to match your repository's directory structure
   - Modify file operations (`cat README.md`) based on your repository contents

4. **Authentication Requirements**:
   - For GitHub: Create a Personal Access Token with repo permissions
   - For GitLab: Create a Project Access Token or Personal Access Token
   - For Bitbucket: Create an App Password with repository read permissions

### Security Best Practices:

- Store Git tokens as Harness secrets, never hardcode them
- Use tokens with minimal required permissions
- Regularly rotate authentication tokens
- Consider using SSH keys for enhanced security in production environments

## Example Scenarios

- **Multi-repository workflows**: Clone additional repositories for dependencies or configuration files
- **Cross-repository operations**: Access files from different repositories within the same pipeline
- **Custom Git workflows**: Implement specific Git operations like sparse checkouts or shallow clones
- **Repository mirroring**: Clone repositories for backup or synchronization purposes
