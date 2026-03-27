# Aegis — AI Full-Stack Quality Guardrails

> _"AI writes code at the speed of thought. Aegis makes sure the thoughts are correct."_

Contract-driven, design-first quality guardrails for AI-assisted full-stack development. Prevents project chaos at scale.

## Problem

AI-assisted development moves fast. Too fast for the design to keep up. Each coding agent sees only its own slice. Mocks pass everywhere, integration day explodes. Aegis solves this with a five-layer protection system.

## Five Layers

```
Design       → Design Brief before code
Contract     → OpenAPI spec + shared types = single source of truth
Implementation → CLAUDE.md constraints + dispatch protocol
Verification → Contract test → Integration test → E2E test
PM           → Gap tracking + sprint phases
```

## Quick Start

```bash
# Initialize Aegis structure in your project
bash scripts/init-project.sh /path/to/your/project
```

This creates `contracts/`, `docs/designs/`, `CLAUDE.md`, and `docker-compose.integration.yml`.

## Usage

This is an [OpenClaw](https://openclaw.ai) AgentSkill. Install it in your OpenClaw workspace and it activates automatically when relevant tasks are detected.

The `SKILL.md` file contains the full workflow documentation.

## Structure

```
aegis-skill/
├── SKILL.md                    # Skill definition + workflow
├── templates/                  # Project templates
│   ├── design-brief.md         # Design Brief template
│   ├── implementation-summary.md
│   ├── claude-md.md            # Enhanced CLAUDE.md
│   ├── api-spec-starter.yaml   # OpenAPI 3.1 starter
│   ├── shared-types-starter.ts
│   ├── errors-starter.yaml
│   └── docker-compose.integration.yml
├── scripts/                    # Automation
│   ├── init-project.sh         # Initialize Aegis in a project
│   ├── validate-contract.sh    # Validate contract consistency
│   └── generate-types.sh       # Generate TypeScript types from spec
└── references/                 # Deep-dive guides
    ├── contract-guide.md
    ├── dispatch-protocol.md
    ├── multi-agent-protocol.md
    └── testing-strategy.md
```

## License

MIT
