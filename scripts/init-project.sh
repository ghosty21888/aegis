#!/usr/bin/env bash
# aegis/scripts/init-project.sh — Initialize Aegis structure in an existing project
# Usage: bash init-project.sh /path/to/project

set -euo pipefail

PROJECT_PATH="${1:?Usage: init-project.sh <project-path>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SKILL_DIR/templates"

if [ ! -d "$PROJECT_PATH" ]; then
  echo "❌ Project path does not exist: $PROJECT_PATH"
  exit 1
fi

echo "🛡️  Initializing Aegis structure in: $PROJECT_PATH"
echo ""

# --- contracts/ ---
CONTRACTS_DIR="$PROJECT_PATH/contracts"
mkdir -p "$CONTRACTS_DIR"

for file in api-spec-starter.yaml shared-types-starter.ts errors-starter.yaml; do
  target_name="${file//-starter/}"  # Remove "-starter" suffix
  target="$CONTRACTS_DIR/$target_name"
  if [ ! -f "$target" ]; then
    cp "$TEMPLATES_DIR/$file" "$target"
    echo "  ✅ Created contracts/$target_name"
  else
    echo "  ⏭️  Skipped contracts/$target_name (already exists)"
  fi
done

# Create empty events schema if not exists
if [ ! -f "$CONTRACTS_DIR/events.schema.json" ]; then
  cat > "$CONTRACTS_DIR/events.schema.json" << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Event Schemas",
  "description": "WebSocket and async event definitions. Add event schemas here.",
  "definitions": {}
}
EOF
  echo "  ✅ Created contracts/events.schema.json"
else
  echo "  ⏭️  Skipped contracts/events.schema.json (already exists)"
fi

# --- docs/designs/ ---
DESIGNS_DIR="$PROJECT_PATH/docs/designs"
mkdir -p "$DESIGNS_DIR"
echo "  ✅ Created docs/designs/"

# Copy design brief template for reference
if [ ! -f "$DESIGNS_DIR/.template.md" ]; then
  cp "$TEMPLATES_DIR/design-brief.md" "$DESIGNS_DIR/.template.md"
  echo "  ✅ Copied design brief template to docs/designs/.template.md"
fi

# --- CLAUDE.md ---
CLAUDE_MD="$PROJECT_PATH/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
  cp "$TEMPLATES_DIR/claude-md.md" "$CLAUDE_MD"
  echo "  ✅ Created CLAUDE.md from Aegis template"
else
  # Check if Aegis section already exists
  if grep -q "Dependencies & Contracts" "$CLAUDE_MD" 2>/dev/null; then
    echo "  ⏭️  Skipped CLAUDE.md (Aegis section already present)"
  else
    echo "" >> "$CLAUDE_MD"
    echo "## 🔗 Dependencies & Contracts (Aegis)" >> "$CLAUDE_MD"
    echo "" >> "$CLAUDE_MD"
    echo "- **API Contract:** \`contracts/api-spec.yaml\` — read before implementing endpoints" >> "$CLAUDE_MD"
    echo "- **Shared Types:** \`contracts/shared-types.ts\` — import from here, never redefine" >> "$CLAUDE_MD"
    echo "- **Error Codes:** \`contracts/errors.yaml\` — use defined codes only" >> "$CLAUDE_MD"
    echo "- **Event Schema:** \`contracts/events.schema.json\` — async event definitions" >> "$CLAUDE_MD"
    echo "  ✅ Appended Aegis contracts section to existing CLAUDE.md"
  fi
fi

# --- docker-compose.integration.yml ---
COMPOSE_FILE="$PROJECT_PATH/docker-compose.integration.yml"
if [ ! -f "$COMPOSE_FILE" ]; then
  cp "$TEMPLATES_DIR/docker-compose.integration.yml" "$COMPOSE_FILE"
  echo "  ✅ Created docker-compose.integration.yml"
else
  echo "  ⏭️  Skipped docker-compose.integration.yml (already exists)"
fi

echo ""
echo "🛡️  Aegis initialization complete!"
echo ""

# --- Auto-setup guardrails ---
echo "🔧 Setting up hard guardrails (language-adaptive)..."
echo ""
# Detect CI platform from git remote
CI_FLAG="github"
if git -C "$PROJECT_PATH" remote get-url origin 2>/dev/null | grep -q "gitlab"; then
  CI_FLAG="gitlab"
fi
bash "$SCRIPT_DIR/setup-guardrails.sh" "$PROJECT_PATH" --ci "$CI_FLAG" 2>&1 || {
  echo "  ⚠️  Guardrails setup had issues (non-fatal). Run manually: bash scripts/setup-guardrails.sh $PROJECT_PATH"
}

echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md — fill in project-specific details"
echo "  2. Edit contracts/api-spec.yaml — define your API endpoints"
echo "  3. Edit contracts/errors.yaml — add domain-specific error codes"
echo "  4. Write your first Design Brief: cp docs/designs/.template.md docs/designs/001-feature.md"
