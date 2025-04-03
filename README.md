## Example Private Data Access in Workflows
This repo contains an example Docker image and Common Workflow Language (CWL) Application Package that can be used with the EO DataHub Workflow Runner to demonstrate accessing private data within workflow steps. This includes access via S3, HTTPS and Resource Catalogue APIs.
To test this workflow, first build this repo using the provided Dockerfile: `docker build -t <image-name>:<tag> .` and then update the following section in the CWL script:
```
hints:
    DockerRequirement:
        dockerPull: <container-repository>/<image-name>:<tag>
```
You can now deploy this workflow to the Workflow Runner and execute the request providing a workflow as an input:
```
{
  "inputs": {
    "workspace": "<your-workspace>"
  }
}
```