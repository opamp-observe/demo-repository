# OpAMP Demo Overlay

This repository is an overlay for an installed `opamp-core` deployment. Copy
these folders into the root of the installed core deployment so the final
layout includes:

```text
<opamp-core-root>/
  cli/config/demo_consumer_profiles.full_multi_agent.json
  demos/full_multi_agent/
```

The overlay does not vendor core services. It expects the installed deployment
to provide `opamp-cli`, `opamp_provider`, `opamp_consumer`, `config_service`,
and `catalog_service`.

## Overlay With Scripts

Windows PowerShell:

```powershell
.\scripts\overlay_opamp_demo.ps1 -CoreRoot "D:\path\to\opamp-core"
```

Linux or macOS:

```bash
chmod +x ./scripts/overlay_opamp_demo.sh
./scripts/overlay_opamp_demo.sh /path/to/opamp-core
```

Then switch to the installed core root:

```powershell
Set-Location "D:\path\to\opamp-core"
opamp-cli cli-config change-config
```

When prompted, choose:

```text
cli/config/demo_consumer_profiles.full_multi_agent.json
```

## Manual Overlay

From this repository root:

```powershell
$coreRoot = "D:\path\to\opamp-core"
New-Item -ItemType Directory -Force -Path "$coreRoot\cli", "$coreRoot\demos" | Out-Null
Copy-Item -Path ".\cli\*" -Destination "$coreRoot\cli" -Recurse -Force
Copy-Item -Path ".\demos\*" -Destination "$coreRoot\demos" -Recurse -Force
```

The current CLI resolves demo profile paths from the installed core root, so the
overlay must be copied into that root before starting the profile.

## Demo

The full multi-agent remote configuration demo is documented in:

```text
demos/full_multi_agent/readme.md
```

It runs Fluent Bit, Fluentd, Vector, Elastic Agent, and Elastic Heartbeat against
one OpAMP provider, with replacement configurations available through the
provider Config Catalog.
