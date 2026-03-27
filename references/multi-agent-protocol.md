# Multi-Agent Coordination Protocol

## Architecture

```
                 ┌──────────────┐
                 │  Lead (Forge) │
                 │ Holds Contract│
                 └──────┬───────┘
                        │
           ┌────────────┼────────────┐
           │            │            │
     ┌─────▼─────┐ ┌───▼───┐ ┌─────▼─────┐
     │ CC-Frontend│ │Contract│ │ CC-Backend │
     │ (Agent A)  │ │  Repo  │ │ (Agent B)  │
     └───────────┘ └───────┘ └───────────┘
```

## Rules

1. **Same contract, same truth.** Both agents receive identical contract files. Neither can modify them unilaterally.

2. **No direct communication.** Agents never talk to each other. All coordination goes through the contract + lead.

3. **Contract changes require approval.** If an agent needs to change the contract, it writes a Change Request. Lead reviews, updates contract, notifies both agents.

4. **Recommended sequence:**
   ```
   contract → backend → contract test → frontend → integration test
   ```
   Backend goes first because frontend depends on real API behavior. But both can start in parallel if the contract is solid.

5. **Backend agent rules:**
   - Implement exactly what the contract defines (no extra endpoints, no missing fields)
   - Write contract tests that validate responses against api-spec.yaml
   - If a design gap is found, document it — don't guess

6. **Frontend agent rules:**
   - Import all types from `contracts/shared-types.ts`
   - During development, mock API using contract-defined schemas
   - Do not invent response formats
   - If contract feels incomplete, file a Change Request

7. **Integration handoff:**
   - Backend completes → lead runs contract tests → green
   - Frontend completes → lead connects to real backend → integration test
   - Both green → E2E test → PR ready

## Contract Change Request Format

```markdown
# Contract Change Request

**Requested by:** {agent name}
**Date:** {YYYY-MM-DD}
**Affects:** {endpoint(s) / schema(s)}

## Current Contract
{What the contract currently says}

## Proposed Change
{What should change}

## Reason
{Why the change is needed — what doesn't work with current contract}

## Impact
- Backend: {needs to change X}
- Frontend: {needs to change Y}
- Tests: {which tests need updating}
```

## Conflict Resolution

When agents disagree (e.g., backend says "this field should be optional" but frontend needs it required):

1. Lead examines the Design Brief for intent
2. Lead decides based on: user needs > API cleanliness > implementation convenience
3. Decision is recorded in Design Brief's "Key Design Decisions" table
4. Contract is updated authoritatively
5. Both agents comply — no exceptions
