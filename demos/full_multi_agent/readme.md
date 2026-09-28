# Full Multi-Agent Demo

This demo is designed to be overlaid into an installed `opamp-core` deployment.
Run the commands below from the installed core root after copying the overlay
contents into that root.

The demo runs five OpAMP consumers against one provider:

| Agent | Consumer mode | Transport | Active config | Replacement config |
|---|---|---|---|---|
| Fluent Bit | Supervisor | WebSocket | `demos/full_multi_agent/active/fluent-bit.yaml` | `demos/full_multi_agent/replacements/fluent-bit.yaml` |
| Fluentd | Supervisor | HTTP | `demos/full_multi_agent/active/fluentd.conf` | `demos/full_multi_agent/replacements/fluentd.conf` |
| Vector | Observer | WebSocket | `demos/full_multi_agent/active/vector.yaml` | `demos/full_multi_agent/replacements/vector.yaml` |
| Elastic Agent | Observer | HTTP | `demos/full_multi_agent/active/elastic-agent.yml` | `demos/full_multi_agent/replacements/elastic-agent.yml` |
| Elastic Heartbeat | Observer | HTTP | `demos/full_multi_agent/active/heartbeat.yml` | `demos/full_multi_agent/replacements/heartbeat.yml` |

The provider config in `demos/full_multi_agent/provider/opamp-provider-full-demo.json`
enables remote config, effective config reporting, and the embedded Config
Catalog. The catalog scans `active/`, `replacements/`, and `consumers/`, so the
files are visible in the server UI at `/catalog`.

For a presentation-ready explanation with diagrams, see
`demos/full_multi_agent/presentation_overview.md`.

## Select The CLI Profile

The overlay provides its demo profile at:

```text
cli/config/demo_consumer_profiles.full_multi_agent.json
```

Select it once from the installed core root:

```powershell
opamp-cli cli-config change-config
```

When prompted, enter:

```text
cli/config/demo_consumer_profiles.full_multi_agent.json
```

## Start

Prepare a demo shell with the expected local agent tools on `PATH`:

```cmd
cmd /k "call demos\full_multi_agent\scripts\use-demo-agent-paths.cmd && powershell"
```

Run the remaining PowerShell commands from that inherited shell.

Start the provider with the overlaid full-demo provider config:

```powershell
$env:OPAMP_CONFIG_PATH = "$PWD\demos\full_multi_agent\provider\opamp-provider-full-demo.json"
python -m opamp_provider.server --config-path $env:OPAMP_CONFIG_PATH --host 127.0.0.1 --port 8080
```

In another shell from the installed core root, start the Logstash container and
all five consumers from the CLI demo profile:

```powershell
$env:OPAMP_DEMO = "true"
opamp-cli start "Demo setup (Full multi-agent remote config)"
```

Start the observer-mode agents before or immediately after starting the
consumers:

```powershell
powershell -ExecutionPolicy Bypass -File demos\full_multi_agent\scripts\start-observed-agents.ps1
```

The helper script accepts command names from `PATH` or explicit executable
paths. By default it looks for these commands on `PATH`:

- `vector`
- `elastic-agent`
- `heartbeat`

Use `scripts/use-demo-agent-paths.cmd` for the default `D:\dev-tools` layout, or
set `PATH` yourself if your local tool layout differs. The script also checks
common Vector locations, including `D:\dev-tools\vector\bin\vector.exe`.

For Vector specifically, you can also set one of these before running the
script:

```powershell
$env:OPAMP_VECTOR_EXECUTABLE_PATH = "D:\dev-tools\vector\bin\vector.exe"
$env:OPAMP_VECTOR_HOME = "D:\dev-tools\vector\bin"
```

You can also pass absolute paths directly:

```powershell
powershell -ExecutionPolicy Bypass -File demos\full_multi_agent\scripts\start-observed-agents.ps1 `
  -VectorExe "D:\dev-tools\vector\bin\vector.exe" `
  -ElasticAgentExe "D:\dev-tools\elastic-agent\elastic-agent-9.5.0-windows-x86_64\elastic-agent.exe" `
  -HeartbeatExe "D:\dev-tools\elastic-heartbeat\heartbeat-9.5.3-windows-x86_64\heartbeat.exe"
```

## Remote Config Demo

Open `http://127.0.0.1:8080/ui`, select a connected client, choose
`Select Configs`, and pick the matching file from
`demos/full_multi_agent/replacements`. The replacement files keep the same
`service_instance_id` values and change output paths or polling/logging behavior
so the deployment is easy to spot.

## Stop

```powershell
opamp-cli stop "Demo setup (Full multi-agent remote config)"
powershell -ExecutionPolicy Bypass -File demos\full_multi_agent\scripts\stop-observed-agents.ps1
```

The Logstash container writes demo events under
`demos/full_multi_agent/out/logstash`.
