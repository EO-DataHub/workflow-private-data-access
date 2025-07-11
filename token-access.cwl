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
          WORKSPACE_TOKEN: <<REPLACE>>
          ENV_DEPLOYMENT: $( inputs.environment )
      InlineJavascriptRequirement: {}
    hints:
      DockerRequirement:
        dockerPull: public.ecr.aws/eodh/test-token-access:0.1.0
    baseCommand: ["python3", "/app/run.py"]
    inputs:
      workspace:
        type: string
        inputBinding:
          position: 1
      environment:
        type: string
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .