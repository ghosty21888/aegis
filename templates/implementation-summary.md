## Implementation Summary

> **Aegis ID:** AEGIS-{project}-{seq}
> **Implemented by:** {agent/person}
> **Date:** {YYYY-MM-DD}
> **PR/MR:** {link}

### Design Conformance

- ✅ {aspect that matches design}
- ✅ {aspect that matches design}
- ⚠️ {deviation from design} — **Reason:** {why} | **Impact:** {what changed}

### File Map

Key logic locations for debugging and review:

| Responsibility | File | Entry Point |
|---------------|------|-------------|
| Request handling | `src/xxx/handler.ts` | `handleRequest()` |
| Business logic | `src/xxx/service.ts` | `processData()` |
| Data access | `src/xxx/repository.ts` | `findById()`, `create()` |
| Validation | `src/xxx/validator.ts` | `validateInput()` |

### Contract Compliance

- [ ] All API responses validated against `contracts/api-spec.yaml`
- [ ] Shared types imported from `contracts/shared-types.ts` (no local redefinitions)
- [ ] Error codes from `contracts/errors.yaml`
- [ ] Contract tests passing

### New Gaps Discovered

<!-- Gaps found during implementation — add to Gap Registry -->

- [ ] **[blocking/non-blocking]** Gap description + impact
- [ ] **[blocking/non-blocking]** Gap description + impact

### Test Coverage

| Layer | Status | Notes |
|-------|--------|-------|
| Unit | ✅ / ❌ | {coverage %} |
| Contract | ✅ / ❌ | {details} |
| Integration | ✅ / ❌ / N/A | {details} |
| E2E | ✅ / ❌ / N/A | {details} |

### Debug Cheatsheet

- **View logs:** `{command}`
- **Check state:** `{command or endpoint}`
- **Common issues:**
  - {symptom} → {cause} → {fix}
