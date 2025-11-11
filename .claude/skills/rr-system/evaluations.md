# Evaluation Scenarios for rr-system

## Scenario 1: Basic Usage - Install Tools on New Machine

**Input:** "Set up my development environment on this new Mac"

**Expected Behavior:**

- Load skill automatically when "setup" or "development environment" mentioned
- Explain the 4-step installation process clearly
- Show exact commands to run in order
- Use TodoWrite to track installation steps
- Provide progress updates for each script execution
- Run scripts in order: install-tools.sh → brew upgrade → install-shell-config.sh → install-ai-configs.sh
- Verify installations after each step
- Instruct user to restart terminal

**Success Criteria:**

- [ ] TodoWrite used to create task list with all 4+ steps
- [ ] Explains what each script does before running it
- [ ] Runs install-tools.sh from correct directory (.claude/skills/rr-system)
- [ ] Emphasizes brew upgrade is MANDATORY after Homebrew install
- [ ] Runs brew upgrade before other scripts
- [ ] Verifies Homebrew installation before proceeding
- [ ] Installs shell configs with proper permissions
- [ ] Installs AI configs with validation
- [ ] Verifies key tools after installation (bat, fish, wt)
- [ ] Instructs user to restart terminal
- [ ] Marks tasks as completed after each step

## Scenario 2: Complex Scenario - Add MCP Server to All AI Platforms

**Input:** "Add the new chrome-devtools MCP server to all my AI assistants (Claude, Codex, Gemini, and OpenCode). It should use npx @modelcontextprotocol/server-chrome-devtools."

**Expected Behavior:**

- Load skill and recognize need to maintain feature parity
- Reference `references/ai-config-schemas.md` for config formats
- Read current configs for all 4 platforms
- Add MCP server definition to each platform (adapting syntax)
- Validate JSON configs with jq
- Validate TOML config with Python tomllib
- Ensure all 4 platforms have the server configured
- Instruct user to restart each AI assistant
- Verify configs are syntactically correct

**Success Criteria:**

- [ ] Reads all 4 config files: ~/.claude/settings.json, ~/.codex/config.toml, ~/.gemini/settings.json, ~/.config/opencode/opencode.json
- [ ] Adds chrome-devtools MCP server to each config
- [ ] Adapts syntax for each platform's format (JSON vs TOML)
- [ ] Uses correct npx command for all platforms
- [ ] Validates Claude config: jq empty ~/.claude/settings.json
- [ ] Validates Codex config: python3 tomllib check
- [ ] Validates Gemini and OpenCode configs: jq empty
- [ ] Maintains consistent server configuration across platforms
- [ ] Instructs user to restart all 4 AI assistants
- [ ] References ai-config-schemas.md for proper formats

## Scenario 3: Error Handling - wt Command Not Found

**Input:** "I ran 'wt new feature-branch' but got 'command not found'. I already ran install-shell-config.sh."

**Expected Behavior:**

- Recognize wt is Fish-specific function
- Check if user is in Fish shell
- Explain wt is only available in Fish
- Provide two solutions:
  1. Switch to Fish shell: `fish` then `wt new feature-branch`
  2. Run from other shell: `fish -c "wt new feature-branch"`
- Verify wt.fish file exists
- Check if Fish is installed
- If Fish not installed, run install-shell-config.sh

**Success Criteria:**

- [ ] Identifies that wt is Fish-only (not bash/zsh)
- [ ] Checks current shell with: echo $SHELL
- [ ] Verifies wt.fish exists: ls ~/.config/fish/functions/wt.fish
- [ ] Provides solution to switch to Fish: `fish`
- [ ] Provides solution to run from other shells: fish -c "wt <cmd>"
- [ ] Explains wt is not available in bash/zsh
- [ ] Tests wt with: fish -c "wt help"
- [ ] If file missing, suggests reinstalling: bash scripts/install-shell-config.sh
- [ ] References troubleshooting section for wt
