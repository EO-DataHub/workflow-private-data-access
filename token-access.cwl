cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.1.2
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  # Workflow entrypoint
  - class: Workflow
    id: token-access
    label: Token Access Test App
    doc: Test Token Access
    requirements:
      ResourceRequirement:
        coresMax: 1
        ramMax: 1024
    inputs:
      workspace:
        label: the workspace to test access for
        doc: workspace to test access
        type: string
      AWS_ACCESS_KEY_ID:
        label: aws access key for S3 access
        type: string
      AWS_SECRET_ACCESS_KEY:
          label: aws secret access key for S3 access
          type: string
      AWS_SESSION_TOKEN:
        label: aws session token for S3 access
        type: string
      WORKSPACE_ACCESS_TOKEN:
        label: the workspace access token for HTTPS access
        type: string
      environment:
        label: the environment to attempt to access
        type: string
    outputs:
      - id: results
        type: Directory
        outputSource:
          - test-access/results
    steps:
      test-access:
        run: "#test-access"
        in:
          workspace: workspace
          aws_key: AWS_ACCESS_KEY_ID
          aws_secret_key: AWS_SECRET_ACCESS_KEY
          aws_session_token: AWS_SESSION_TOKEN
          workspace_access_token: WORKSPACE_ACCESS_TOKEN
          environment: environment
        out:
          - results
  # convert.sh - takes input args `--url`
  - class: CommandLineTool
    id: test-access
    requirements:
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
      EnvVarRequirement:
        envDef:
          AWS_ACCESS_KEY_ID: $( inputs.aws_key )
          AWS_SECRET_ACCESS_KEY: $( inputs.aws_secret_key )
          AWS_SESSION_TOKEN: $( inputs.aws_session_token )
          WORKSPACE_ACCESS_TOKEN: $( inputs.workspace_access_token )
          ENV_DEPLOYMENT: $( inputs.environment )
      InlineJavascriptRequirement: {}
    hints:
      DockerRequirement:
        dockerPull: public.ecr.aws/eodh/test-token-access:0.0.25
    baseCommand: ["python3", "/app/run.py"]
    inputs:
      workspace:
        type: string
        inputBinding:
          position: 1
      environment:
        type: string
      aws_key:
        type: string
      aws_secret_key:
          type: string
      aws_session_token:
        type: string
      workspace_access_token:
        type: string
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .