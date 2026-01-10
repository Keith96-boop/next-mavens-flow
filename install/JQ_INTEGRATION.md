# jq Integration for Maven Flow

## System Updated: jq is now required and integrated

### What Changed

1. **flow.md hook** - Now uses `jq` for robust JSON parsing
   - Falls back to `grep` if jq is not available
   - Provides better error messages

2. **install-simple.sh/ps1** - Updated to check and install jq
   - Automatically installs jq if missing
   - Shows jq version during installation

3. **New installers** - Cross-platform jq installers
   - `install/install-jq.sh` - Unix/Linux/macOS
   - `install/install-jq.ps1` - Windows

### Hook Behavior

**Before (grep only):**
```bash
if echo "$TOOL_INPUT" | grep -q '"subagent_type"[[:space:]]*:[[:space:]]*"flow-iteration"'; then
```

**After (jq + fallback):**
```bash
if ! command -v jq >/dev/null 2>&1; then
    # Fallback to grep pattern matching
    echo "Warning: jq not found. JSON parsing will be less robust." >&2
else
    # Use jq for robust JSON parsing
    SUBAGENT_TYPE=$(echo "$TOOL_INPUT" | jq -r '.subagent_type // empty')
fi
```

### Benefits

| Aspect | grep (old) | jq (new) |
|--------|------------|----------|
| Robustness | Pattern matching only | Proper JSON parsing |
| Whitespace handling | Brittle | Handles all formats |
| Nested objects | Not supported | Full support |
| Error messages | Generic | Specific |
| Future-proofing | Fragile | Reliable |

### Verification

```bash
# Check jq is installed
jq --version

# Test hook logic
echo '{"subagent_type":"flow-iteration"}' | jq -r '.subagent_type'
# Output: flow-iteration

# Verify PRD validation
ls docs/prd-*.json
```

### Migration Notes

- **Existing users**: Hook now uses jq if available (graceful fallback)
- **New users**: jq is installed automatically via install scripts
- **No breaking changes**: System works with or without jq

### Current System Status

- ✅ jq 1.8.1 installed
- ✅ flow.md updated with jq support
- ✅ Global installers copied to ~/.claude/
- ✅ Hook tested and working
