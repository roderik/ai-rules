# Workflow Audit for rr-system

## ✓ Passed

- Development Workflow section exists ("Essential Workflows" starting line 231)
- Clear numbered/sequential workflow steps (4-step installation process)
- Progress reporting requirements section (lines 30-52) enforces TodoWrite usage
- Multiple conditional workflows present:
  - "Setting Up New Machine" workflow
  - "Updating Existing Installation" workflow
  - "Adding MCP Server to All Platforms" workflow
  - "Checking System Status" workflow
- Comprehensive verification steps included
- Clear feedback loops with validation commands
- Troubleshooting section with recovery procedures (lines 321-401)
- Excellent conditional guidance ("If X then Y" patterns throughout)

## ✗ Missing/Needs Improvement

- Quick Installation section (lines 54-74) lacks checkboxes
- Essential Workflows section uses prose instead of checklist format
- "Setting Up New Machine" workflow has verification section but no checkbox format
- "Adding MCP Server to All Platforms" workflow lacks explicit checklist
- No explicit rollback procedures for failed installations
- No pre-installation requirements checklist
- Validation steps scattered throughout, not consolidated

## Recommendations

1. **Add pre-installation checklist**:

   ```markdown
   ### Pre-Installation Requirements

   - [ ] macOS or Linux system
   - [ ] Terminal access
   - [ ] Internet connection
   - [ ] User has sudo permissions (for shell registration)
   - [ ] Backup existing shell configs (if any)
   ```

2. **Convert Quick Installation to checklist format**:

   ```markdown
   ## Quick Installation

   Complete 5-step setup on macOS or Linux:

   - [ ] **Install tools**: `bash scripts/install-tools.sh`
   - [ ] **Upgrade packages** (MANDATORY): `brew upgrade`
   - [ ] **Install shell configs**: `bash scripts/install-shell-config.sh`
   - [ ] **Install AI configs**: `bash scripts/install-ai-configs.sh`
   - [ ] **Restart terminal** and verify installation
   ```

3. **Add verification checklist to Setting Up New Machine**:

   ```markdown
   ### Verification Checklist

   - [ ] `bat --version` - bat installed and working
   - [ ] `fish --version` - Fish shell installed
   - [ ] `ls ~/.config/fish/config.fish` - Fish config exists
   - [ ] `ls ~/.claude/settings.json` - Claude config exists
   - [ ] `fish -c "wt help"` - wt function works
   - [ ] Modern CLI tools respond to `--version`
   ```

4. **Add MCP Server workflow as explicit checklist**:

   ```markdown
   ### Adding MCP Server to All Platforms

   To maintain feature parity:

   - [ ] Load `references/ai-config-schemas.md` for formats
   - [ ] **For Claude**: Add server to `~/.claude/settings.json`, validate with `jq empty`
   - [ ] **For Codex**: Add server to `~/.codex/config.toml`, validate with Python tomllib
   - [ ] **For Gemini**: Add server to `~/.gemini/settings.json`, validate with `jq empty`
   - [ ] **For OpenCode**: Add server to `~/.config/opencode/opencode.json`, validate with `jq empty`
   - [ ] Verify all 4 configs have server definition
   - [ ] Restart each AI assistant
   - [ ] Test server functionality on each platform
   ```

5. **Add rollback procedures**:

   ```markdown
   ### Rollback Procedures

   If installation fails or causes issues:

   **Rollback Homebrew installation**:

   - Backup brew list: `brew list > brew-backup.txt`
   - Uninstall Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"`

   **Restore shell configs**:

   - `mv ~/.config/fish/config.fish.backup ~/.config/fish/config.fish`
   - `source ~/.config/fish/config.fish`

   **Restore AI configs**:

   - Restore from backups in `~/.claude.backup/`, `~/.codex.backup/`, etc.
   ```

6. **Add failure handling to workflows**:
   - "If brew upgrade fails, check internet connection and retry"
   - "If shell config installation fails, check permissions"
   - "If AI config validation fails, review JSON/TOML syntax errors"

7. **Consolidate validation commands**:
   Create a "Post-Installation Validation" section with all checks in one place.
