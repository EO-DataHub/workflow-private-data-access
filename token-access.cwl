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
      aws_key:
        label: the workspace to test access for
        doc: workspace to test access
        type: string
      aws_secret_key:
          label: the workspace to test access for
          doc: workspace to test access
          type: string
      aws_session_token:
        label: the workspace to test access for
        doc: workspace to test access
        type: string
      workspace_access_token:
        label: the workspace to test access for
        doc: workspace to test access
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
          aws_key: aws_key
          aws_secret_key: aws_secret_key
          aws_session_token: aws_session_token
          workspace_access_token: workspace_access_token
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
      InlineJavascriptRequirement: {}
    hints:
      DockerRequirement:
        dockerPull: public.ecr.aws/eodh/test-token-access:0.0.1
    baseCommand: ["python3", "/app/run.py"]
    inputs:
      workspace:
        type: string
        inputBinding:
          position: 1
      aws_key:
        label: the workspace to test access for
        doc: workspace to test access
        type: string
      aws_secret_key:
          label: the workspace to test access for
          doc: workspace to test access
          type: string
      aws_session_token:
        label: the workspace to test access for
        doc: workspace to test access
        type: string
      workspace_access_token:
        label: the workspace to test access for
        doc: workspace to test access
        type: string
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .