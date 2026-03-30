# Testing Strategy — Aegis Approach

## The Problem with AI-Generated Tests

AI agents love to mock everything. The result: all tests pass, but the system doesn't work.

Aegis enforces a testing pyramid where **mocks are only allowed at the bottom layer**.

## Testing Pyramid

```
         ╱  E2E Test  ╲          ← Real browser + real backend
        ╱───────────────╲
       ╱ Integration Test╲       ← Real services via docker-compose
      ╱───────────────────╲
     ╱   Contract Test     ╲     ← Validates conformance to contract
    ╱───────────────────────╲
   ╱     Unit Test           ╲   ← Pure logic, mocks allowed
  ╱───────────────────────────╲
```

## Layer Details

### Unit Tests
- **What:** Pure business logic, utilities, transformations
- **Mocks:** Yes — external dependencies (DB, HTTP, etc.)
- **Speed:** Milliseconds
- **When:** Every code change

### Contract Tests
- **What:** Does the implementation match the contract?
- **Backend (Provider):** Start the real server, hit endpoints, validate response against OpenAPI spec
- **Frontend (Consumer):** Build test data from contract types, verify components handle them correctly
- **Mocks:** Only for dependencies external to the contract scope
- **Speed:** Seconds
- **When:** Every code change that touches an API

### Integration Tests
- **What:** Do all services work together?
- **Setup:** docker-compose with real database, real backend, real frontend
- **Mocks:** None
- **Speed:** Minutes
- **When:** Before merge

### E2E Tests
- **What:** Does the deployed system work from a user's perspective?
- **Setup:** Playwright against a real deployment
- **Mocks:** None
- **Speed:** Minutes
- **When:** After deployment, before release

## Frontend Testing Standard (Production-Ready)

When the project has a frontend, these are **mandatory**, not optional:

### Required Stack
| Tool | Role |
|------|------|
| **Vitest** | Test runner (fast, ESM-native, Vite-compatible) |
| **React Testing Library** | Component testing (or framework equivalent: Vue Testing Library, etc.) |
| **MSW (Mock Service Worker)** | API mocking at the network level |

### Coverage Requirements

1. **API Client Tests** — every API function must be tested:
   - Normal response (200)
   - Error response (4xx, 5xx)
   - Authentication handling (token injection, 401 refresh/redirect)

2. **Data Hooks Tests** — every data-fetching hook (React Query, SWR, etc.) must cover:
   - Loading state
   - Success state (with realistic data from contract types)
   - Error state (network failure, API error)

3. **Key Component Rendering** — critical UI components must have render tests:
   - Renders with valid data
   - Renders empty/loading state
   - Renders error state
   - User interactions trigger expected callbacks

4. **MSW Handlers** — must mock **every backend endpoint** the frontend calls:
   - Response shapes must match `contracts/shared-types.ts` exactly
   - Use contract-defined types to build mock data (never ad-hoc)
   - Include error handlers for testing error paths

### CI Gate
- `pnpm test` (or equivalent) must pass in CI — **not optional, not "nice to have"**
- Failed frontend tests = blocked PR, same as backend

### Design Brief Integration
When a feature touches frontend, the Design Brief's **Testing Strategy** section must define:
- Which API clients need tests
- Which hooks need tests  
- Which components are "key" and need render tests
- MSW handler coverage plan

## Backend Integration Testing Standard (HTTP E2E)

Standard Aegis integration tests use docker-compose at the service level. This standard goes further — **every API endpoint must have HTTP-level E2E tests**.

### What This Means

```
Start real HTTP server
  → Send real HTTP requests (fetch/supertest/httptest)
  → Hit real database (isolated test DB, not mocks)
  → Validate complete HTTP response (status + headers + body)
  → Verify side effects (GET after POST to confirm mutation)
```

### Coverage Per Endpoint

Every endpoint must have tests for:

| Scenario | What to verify |
|----------|---------------|
| **Happy path (200/201)** | Correct response body matches contract schema |
| **Bad request (400)** | Missing/invalid params return proper error from `errors.yaml` |
| **Not found (404)** | Non-existent resource returns 404 with correct error code |
| **Auth failure (401/403)** | Missing/invalid/expired token returns proper auth error |
| **Mutation verification** | After POST/PUT/DELETE → GET the resource → confirm state change |

### Real Dependencies, Not Mocks

- **Database:** Use a real test database (SQLite in-memory for simple cases, containerized Postgres/MySQL for production parity)
- **Test isolation:** Each test suite gets a clean DB state (migrations + seed, or transaction rollback)
- **External services:** Only mock truly external third-party APIs (Stripe, SendGrid, etc.) — internal services stay real

### CI Gate
- Integration tests must run in CI after unit + contract tests
- Pipeline order: `lint → type-check → unit → contract → integration → build → E2E`

### Design Brief Integration
When a feature adds or modifies API endpoints, the Design Brief must include:
- List of endpoints requiring integration tests
- Expected test scenarios per endpoint (at minimum: happy path + auth + not found)
- Database setup requirements (what seed data is needed)

## Test Strategy in Design Review (Mandatory Gate)

**When a project includes both frontend and backend**, the Design Brief's Testing Strategy section must define **all three layers upfront**:

1. **Frontend tests:** API client coverage, hook coverage, key component list, MSW plan
2. **Backend integration tests:** endpoint list, scenario matrix, DB setup
3. **E2E tests:** critical user flows that need browser-level verification

This is a **Design Review gate** — a Design Brief without a complete testing strategy for a full-stack feature cannot be approved. Testing is designed before code, not bolted on after.

## Key Principles

1. **Never mock across contract boundaries** — If frontend tests mock the API, you're testing your assumptions, not the system
2. **Contract tests are mandatory** — They're cheap and catch 80% of integration issues
3. **Integration tests prove it works** — docker-compose is your safety net
4. **E2E tests validate the user experience** — Not every flow, just the critical paths
5. **Frontend tests are not second-class** — Same rigor as backend. Same CI gates. Same blocking power.
6. **Test strategy is a design artifact** — Define it in the Design Brief, before writing code. Not after.
