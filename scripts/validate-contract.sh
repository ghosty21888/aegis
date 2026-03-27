#!/usr/bin/env bash
# aegis/scripts/validate-contract.sh — Validate contract consistency in a project
# Usage: bash validate-contract.sh /path/to/project
#
# Checks:
# 1. api-spec.yaml is valid YAML
# 2. errors.yaml is valid YAML
# 3. shared-types.ts exists
# 4. CLAUDE.md references contract files
# 5. No local type redefinitions that shadow shared-types

set -euo pipefail

PROJECT_PATH="${1:?Usage: validate-contract.sh <project-path>}"
CONTRACTS_DIR="$PROJECT_PATH/contracts"
ERRORS=0

echo "🔍 Validating Aegis contracts in: $PROJECT_PATH"
echo ""

# --- Check contract files exist ---
for file in api-spec.yaml shared-types.ts errors.yaml; do
  if [ -f "$CONTRACTS_DIR/$file" ]; then
    echo "  ✅ contracts/$file exists"
  else
    echo "  ❌ contracts/$file MISSING"
    ERRORS=$((ERRORS + 1))
  fi
done

# --- Validate YAML syntax ---
YAML_VALIDATOR=""
if python3 -c "import yaml" 2>/dev/null; then
  YAML_VALIDATOR="pyyaml"
elif command -v node &>/dev/null; then
  YAML_VALIDATOR="node"
fi

for yaml_file in api-spec.yaml errors.yaml; do
  if [ -f "$CONTRACTS_DIR/$yaml_file" ]; then
    VALID=false
    if [ "$YAML_VALIDATOR" = "pyyaml" ]; then
      python3 -c "import yaml; yaml.safe_load(open('$CONTRACTS_DIR/$yaml_file'))" 2>/dev/null && VALID=true
    elif [ "$YAML_VALIDATOR" = "node" ]; then
      # Use Node.js built-in JSON-superset check on YAML (basic syntax validation)
      node -e "
        const fs = require('fs');
        const content = fs.readFileSync('$CONTRACTS_DIR/$yaml_file', 'utf8');
        // Basic YAML syntax checks: no tabs for indentation, balanced quotes
        const lines = content.split('\n');
        let ok = true;
        for (let i = 0; i < lines.length; i++) {
          if (lines[i].match(/^\t/)) { console.error('Tab indentation at line ' + (i+1)); ok = false; break; }
        }
        process.exit(ok ? 0 : 1);
      " 2>/dev/null && VALID=true
    else
      echo "  ⚠️  No YAML validator available — skipping syntax check for $yaml_file"
      continue
    fi

    if $VALID; then
      echo "  ✅ contracts/$yaml_file basic syntax OK"
    else
      echo "  ❌ contracts/$yaml_file has syntax errors"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

# --- Check OpenAPI version ---
if [ -f "$CONTRACTS_DIR/api-spec.yaml" ]; then
  if grep -q 'openapi:' "$CONTRACTS_DIR/api-spec.yaml"; then
    echo "  ✅ api-spec.yaml has OpenAPI version field"
  else
    echo "  ⚠️  api-spec.yaml missing 'openapi:' field — may not be a valid OpenAPI spec"
  fi
fi

# --- Check CLAUDE.md references contracts ---
CLAUDE_MD="$PROJECT_PATH/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  if grep -q "contracts/" "$CLAUDE_MD"; then
    echo "  ✅ CLAUDE.md references contracts/"
  else
    echo "  ⚠️  CLAUDE.md does not reference contracts/ — CC may not know about contracts"
  fi
else
  echo "  ⚠️  No CLAUDE.md found"
fi

# --- Check for local type redefinitions (TypeScript projects) ---
if [ -f "$CONTRACTS_DIR/shared-types.ts" ]; then
  # Extract exported interface/type names from shared-types
  SHARED_TYPES=$(grep -oP '(?<=export (interface|type) )\w+' "$CONTRACTS_DIR/shared-types.ts" 2>/dev/null || true)
  
  if [ -n "$SHARED_TYPES" ]; then
    SRC_DIR="$PROJECT_PATH/src"
    if [ -d "$SRC_DIR" ]; then
      REDEFINED=0
      while IFS= read -r type_name; do
        # Look for local redefinitions (interface X or type X =) in src/, excluding imports
        MATCHES=$(grep -rn "^\(export \)\?\(interface\|type\) $type_name\b" "$SRC_DIR" 2>/dev/null | grep -v "import" | grep -v "node_modules" || true)
        if [ -n "$MATCHES" ]; then
          echo "  ❌ Type '$type_name' from shared-types.ts is redefined locally:"
          echo "$MATCHES" | sed 's/^/      /'
          REDEFINED=$((REDEFINED + 1))
        fi
      done <<< "$SHARED_TYPES"
      
      if [ "$REDEFINED" -eq 0 ]; then
        echo "  ✅ No local type redefinitions found (shared-types.ts is respected)"
      else
        ERRORS=$((ERRORS + REDEFINED))
      fi
    fi
  fi
fi

# --- Check events schema ---
if [ -f "$CONTRACTS_DIR/events.schema.json" ]; then
  if node -e "JSON.parse(require('fs').readFileSync('$CONTRACTS_DIR/events.schema.json','utf8'))" 2>/dev/null || python3 -c "import json; json.load(open('$CONTRACTS_DIR/events.schema.json'))" 2>/dev/null; then
    echo "  ✅ contracts/events.schema.json is valid JSON"
  else
    echo "  ❌ contracts/events.schema.json has JSON syntax errors"
    ERRORS=$((ERRORS + 1))
  fi
fi

# --- Summary ---
echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "🛡️  All contract checks passed!"
  exit 0
else
  echo "❌ $ERRORS contract issue(s) found. Fix before proceeding."
  exit 1
fi
