# Testing Strategy — Aegis Verification Layer

## Test Pyramid (AI-Dev Specialized)

```
         E2E Test              ← Real browser + real backend (playwright-forge)
       Integration Test        ← Real services via docker compose
     Contract Test             ← Each side validates against contract
   Unit Test                   ← Pure logic (mocking allowed here only)
```

**Key principle:** Mocking only at the bottom. Every layer above uses real services.

## Unit Tests

Standard unit tests. Mock external dependencies. Test pure business logic.

No special Aegis rules here — follow normal best practices.

## Contract Tests

The key Aegis innovation. Instead of testing against invented mock data, test against the contract.

### Backend — Provider Contract Test

Validate that API responses conform to the OpenAPI spec:

```typescript
// tests/contract/users.provider.test.ts
import { validateResponse } from '../helpers/contract-validator';
import { loadSpec } from '../helpers/spec-loader';

const spec = loadSpec('contracts/api-spec.yaml');

describe('GET /api/users', () => {
  it('response conforms to contract', async () => {
    const response = await request(app).get('/api/users');
    const result = validateResponse(spec, 'GET', '/api/users', response.status, response.body);
    expect(result.valid).toBe(true);
    if (!result.valid) console.error(result.errors);
  });

  it('error response conforms to contract', async () => {
    const response = await request(app).get('/api/users/nonexistent');
    const result = validateResponse(spec, 'GET', '/api/users/{id}', response.status, response.body);
    expect(result.valid).toBe(true);
  });
});
```

### Frontend — Consumer Contract Test

Build test data from contract types, not ad-hoc:

```typescript
// tests/contract/users.consumer.test.ts
import { ApiResponse, User } from '../../contracts/shared-types';

describe('UserList component', () => {
  it('renders contract-compliant data', () => {
    // Data shaped by contract, not imagination
    const response: ApiResponse<User[]> = {
      success: true,
      data: [{
        id: '1',
        username: 'test',
        email: 'test@example.com',
        createdAt: '2026-01-01T00:00:00Z'
      }]
    };

    render(<UserList data={response} />);
    expect(screen.getByText('test')).toBeInTheDocument();
  });

  it('handles contract error format', () => {
    const errorResponse: ApiResponse<never> = {
      success: false,
      error: { code: 'SYS_NOT_FOUND', message: 'User not found' }
    };

    render(<UserList data={errorResponse} />);
    expect(screen.getByText('User not found')).toBeInTheDocument();
  });
});
```

### Go Backend — Provider Contract Test

```go
// internal/handler/users_contract_test.go
func TestListUsers_ContractCompliance(t *testing.T) {
    // Load OpenAPI spec
    spec, err := loadSpec("../../contracts/api-spec.yaml")
    require.NoError(t, err)

    // Make request
    req := httptest.NewRequest("GET", "/api/users", nil)
    w := httptest.NewRecorder()
    handler.ServeHTTP(w, req)

    // Validate response against spec
    err = validateResponse(spec, "GET", "/api/users", w.Code, w.Body.Bytes())
    assert.NoError(t, err, "Response does not match contract")
}
```

## Integration Tests

Use `docker-compose.integration.yml` to spin up real services:

```bash
docker compose -f docker-compose.integration.yml up --build -d
# Wait for services to be healthy
docker compose -f docker-compose.integration.yml run test-runner
docker compose -f docker-compose.integration.yml down
```

Integration tests verify:
- Real HTTP calls between frontend and backend
- Real database operations
- Real authentication flow
- Real error scenarios

## E2E Tests

Use playwright-forge for browser-level verification:

```bash
curl -X POST http://playwright-forge:3000/run/async \
  -H "Content-Type: application/json" \
  -d '{
    "url": "http://frontend:3000",
    "scenarios": ["explore", "responsive", "functional"],
    "upload": {"type": "slack", "credential": "SLACK_BOT", "channel": "#project-channel"},
    "functional": {
      "steps": [
        {"action": "navigate", "url": "/login"},
        {"action": "fill", "selector": "#email", "value": "test@example.com"},
        {"action": "click", "selector": "button[type=submit]"},
        {"action": "wait", "selector": ".dashboard"},
        {"action": "screenshot", "name": "login-flow"}
      ]
    }
  }'
```

## CI Pipeline

Recommended CI order:

```yaml
stages:
  - lint        # eslint/golangci-lint + type-check
  - unit        # Unit tests (fast, mocking OK)
  - contract    # Contract tests (validate against spec)
  - build       # Docker images
  - integration # docker compose + real services
  - e2e         # playwright-forge (if applicable)
```

**Gate rule:** No stage can pass if the previous one failed. Contract tests are the minimum bar — even Lite Mode requires them.
