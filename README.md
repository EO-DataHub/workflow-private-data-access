## Example Private Data Access in Workflows
This repo contains an example Docker image and Common Workflow Language (CWL) Application Package that can be used with the EO DataHub Workflow Runner to demonstrate accessing private data within workflow steps. This includes access via mounted block store, S3, HTTPS and Resource Catalogue APIs.
To test this workflow, first build this repo using the provided Dockerfile: `docker build -t <image-name>:<tag> .` and then push this to a remote repository so the image can be pulled later. Then update the following section in the CWL script:
```
hints:
    DockerRequirement:
        dockerPull: <container-repository>/<image-name>:<tag>
```
You can now deploy this workflow to the Workflow Runner and execute the request providing a workspace as an input, note this will need to be the workspace in which the workflow is going to be run, to ensure the correct access credentials will be provided by the workflow runner:
```
{
  "inputs": {
    "workspace": "<your-workspace>"
  }
}
```

The image is available publicly at public.ecr.aws/eodh/test-token-access, as used in the CWL script.
