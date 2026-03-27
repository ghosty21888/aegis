# CLAUDE.md — {Project Name}

## Project Overview

<!-- One paragraph: what this project is, who it serves. -->

## Architecture

<!-- From Design Brief: key modules, data flow, dependencies. Keep it concise —
     CC should understand the system shape, not every detail. -->

## ⛔ Hard Constraints (violate = PR rejected)

<!-- These are non-negotiable. CC must follow them or the work gets rejected. -->

- All API responses MUST conform to `contracts/api-spec.yaml`
- Shared types MUST be imported from `contracts/shared-types.ts` — never redefine locally
- Error codes MUST use `contracts/errors.yaml` definitions
- Database migrations MUST be reversible
- No business logic in controller/handler layer (controller → service → repository)
- No hardcoded environment variable values
- No `any` type in TypeScript (use `unknown` + type guards if needed)
- All public APIs MUST have JSDoc/docstring

## 📋 Code Standards

### Naming

- Files: `kebab-case.ts` / `snake_case.go`
- Functions/methods: `camelCase` (TS) / `PascalCase` exported, `camelCase` unexported (Go)
- Constants: `UPPER_SNAKE_CASE`
- Database fields: `snake_case`

### Directory Structure

<!-- Define the canonical project structure CC should follow -->

```
src/
├── handlers/          # HTTP handlers (thin — delegate to services)
├── services/          # Business logic
├── repositories/      # Data access
├── models/            # Domain models
├── middleware/         # Auth, logging, error handling
├── utils/             # Shared utilities
└── config/            # Configuration loading
```

### Import Order

1. Standard library
2. External dependencies
3. Internal packages (absolute paths)
4. Relative imports

### Logging

- Use structured logging (JSON format)
- Every request MUST include `requestId`
- Log levels: `error` (failures), `warn` (degraded), `info` (key events), `debug` (detail)
- Never log sensitive data (tokens, passwords, PII)

### Error Handling

- Always return typed errors — never swallow errors silently
- Use error codes from `contracts/errors.yaml`
- Wrap errors with context: `fmt.Errorf("createUser: %w", err)` / `throw new AppError(code, message, cause)`
- HTTP handlers: catch all errors → map to contract-defined error response format

## 🧪 Testing Requirements

- New API endpoint → MUST have contract test
- Business logic → MUST have unit test
- Modified existing API → MUST update contract + related tests
- Core module test coverage: >80%
- Run `npm test` / `go test ./...` before committing

## 📁 Current Project Structure

<!-- Keep this updated as the project evolves -->

```
{project-root}/
├── contracts/               # Aegis contracts (source of truth)
│   ├── api-spec.yaml
│   ├── shared-types.ts
│   ├── events.schema.json
│   └── errors.yaml
├── docs/designs/            # Design Briefs
├── src/                     # Source code
├── tests/                   # Test files
├── docker-compose.yml       # Development
├── docker-compose.integration.yml  # Integration testing
└── CLAUDE.md               # This file
```

## 🔗 Dependencies & Contracts

- **API Contract:** `contracts/api-spec.yaml` — read this before implementing any endpoint
- **Shared Types:** `contracts/shared-types.ts` — import types from here
- **Error Codes:** `contracts/errors.yaml` — use defined codes only
- **Event Schema:** `contracts/events.schema.json` — for async events

## 🐛 Known Issues & Gaps

<!-- Synced from Gap Registry. Update when gaps are resolved or new ones discovered. -->

- None yet

## 📝 Recent Design Decisions

<!-- Last 5 decisions from Design Briefs. Helps CC understand historical context. -->

| Date | Decision | Rationale |
|------|----------|-----------|
