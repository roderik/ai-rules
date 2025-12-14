# feat: Add grc (Generic Colourizer) Integration for All Shells

## Overview

Add grc (Generic Colourizer) integration to Bash, Zsh, and Fish shell configurations. grc automatically colorizes output from common CLI commands like `ping`, `df`, `dig`, `netstat`, `traceroute`, and many more, making terminal output more readable and visually informative.

## Problem Statement / Motivation

CLI tools output plain monochrome text by default, making it harder to scan and parse information quickly. While individual tools like `bat` (cat) and `eza` (ls) provide colorized alternatives, many system commands (`ping`, `df`, `dig`, `netstat`, `traceroute`, etc.) still output plain text.

grc solves this by wrapping commands with ANSI color codes, providing consistent colorization across 40+ commonly used CLI tools without replacing them.

**Why this matters:**

- Improved readability of network diagnostics (`ping`, `traceroute`, `dig`, `netstat`)
- Better scanning of system info (`df`, `free`, `mount`, `lsblk`)
- Easier debugging of builds (`make`, `gcc`, `g++`)
- Consistent visual experience across tools

## Proposed Solution

Create three new configuration files following the existing `conf.d/` pattern:

1. `86-grc.bash` - Bash integration
2. `86-grc.zsh` - Zsh integration
3. `86-grc.fish` - Fish integration

**Key Design Decisions:**

### 1. Selective Command Wrapping (Not All)

**Decision:** Only wrap commands that don't conflict with existing aliases and provide clear value.

**Exclude from wrapping:**

- `cat` - conflicts with `bat` alias in `86-additional-tools.*`
- `ps` - conflicts with `procs` alias in `86-additional-tools.*`
- `ls` - conflicts with `eza` aliases in shell configs
- `diff` - may conflict with `delta` integration

**Include (safe, high-value):**

- Network: `ping`, `ping6`, `traceroute`, `traceroute6`, `dig`, `netstat`, `mtr`, `nmap`, `ss`, `ifconfig`, `ip`
- System: `df`, `du`, `free`, `mount`, `lsblk`, `lsof`, `fdisk`, `findmnt`, `blkid`
- Build: `make`, `gcc`, `g++`, `configure`
- Container: `docker`, `docker-compose`, `kubectl`
- Misc: `journalctl`, `systemctl`, `env`, `id`, `uptime`, `w`, `who`

### 2. Homebrew Prefix Detection

**Pattern:** Check Apple Silicon path first (`/opt/homebrew`), fall back to Intel path (`/usr/local`).

```bash
# Detect Homebrew prefix
if [[ -d "/opt/homebrew" ]]; then
  HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  HOMEBREW_PREFIX="/usr/local"
fi
```

### 3. Conditional Loading

Only load grc integration if:

1. `grc` command exists
2. Shell is interactive (TTY check)
3. `$TERM` is not "dumb"
4. grc shell integration file exists at Homebrew prefix

### 4. No Disable Mechanism (KISS)

Users can disable by:

- Removing/renaming the `86-grc.*` file
- Uninstalling grc (`brew uninstall grc`)
- Setting `GRC_ALIASES=false` before sourcing (Bash only)

## Technical Approach

### File: `conf.d/86-grc.bash`

```bash
#!/usr/bin/env bash
# grc (Generic Colourizer) integration
# https://github.com/garabik/grc

# Skip if grc not installed
command -v grc &> /dev/null || return 0

# Skip if not interactive
[[ $- != *i* ]] && return 0
[ -z "$TERM" ] || [ "$TERM" = "dumb" ] && return 0

# Detect Homebrew prefix
if [[ -d "/opt/homebrew" ]]; then
  _grc_prefix="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  _grc_prefix="/usr/local"
else
  return 0
fi

# Check if grc.sh exists
_grc_sh="${_grc_prefix}/etc/grc.sh"
[[ -f "$_grc_sh" ]] || return 0

# Enable grc aliases and source
export GRC_ALIASES=true
source "$_grc_sh"

# Remove conflicting aliases (we prefer our tools)
unalias cat 2>/dev/null  # Keep bat
unalias ps 2>/dev/null   # Keep procs
unalias ls 2>/dev/null   # Keep eza
unalias diff 2>/dev/null # Keep delta

unset _grc_prefix _grc_sh
```

### File: `conf.d/86-grc.zsh`

```zsh
#!/usr/bin/env zsh
# grc (Generic Colourizer) integration
# https://github.com/garabik/grc

# Skip if grc not installed
(( $+commands[grc] )) || return 0

# Skip if not interactive
[[ -o interactive ]] || return 0
[[ -n "$TERM" && "$TERM" != "dumb" ]] || return 0

# Detect Homebrew prefix
local _grc_prefix
if [[ -d "/opt/homebrew" ]]; then
  _grc_prefix="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  _grc_prefix="/usr/local"
else
  return 0
fi

# Check if grc.zsh exists
local _grc_zsh="${_grc_prefix}/etc/grc.zsh"
[[ -f "$_grc_zsh" ]] || return 0

# Source grc integration
source "$_grc_zsh"

# Remove conflicting functions (we prefer our tools)
# grc.zsh creates functions, not aliases
unfunction cat 2>/dev/null  # Keep bat
unfunction ps 2>/dev/null   # Keep procs
unfunction ls 2>/dev/null   # Keep eza
unfunction diff 2>/dev/null # Keep delta
```

### File: `conf.d/86-grc.fish`

```fish
#!/usr/bin/env fish
# grc (Generic Colourizer) integration
# https://github.com/garabik/grc

# Skip if grc not installed
type -q grc; or exit 0

# Skip if not interactive
status is-interactive; or exit 0

# Detect Homebrew prefix
set -l _grc_prefix
if test -d "/opt/homebrew"
    set _grc_prefix "/opt/homebrew"
else if test -d "/usr/local/Homebrew"
    set _grc_prefix "/usr/local"
else
    exit 0
end

# Check if grc.fish exists
set -l _grc_fish "$_grc_prefix/etc/grc.fish"
test -f "$_grc_fish"; or exit 0

# Override grc_plugin_execs to exclude conflicting commands
# Exclude: cat (bat), ps (procs), ls (eza), diff (delta)
set -g grc_plugin_execs cvs df dig gcc g++ ifconfig \
    make mount mtr netstat ping tail traceroute \
    wdiff blkid du dnf docker docker-compose docker-machine env id ip iostat journalctl kubectl \
    last lsattr lsblk lspci lsmod lsof getfacl getsebool ulimit uptime nmap \
    fdisk findmnt free semanage sar ss sysctl systemctl stat showmount \
    tcpdump tune2fs vmstat w who sockstat

# Source grc integration
source "$_grc_fish"
```

## Acceptance Criteria

### Functional Requirements

- [ ] grc colorizes `ping google.com` output in all three shells
- [ ] grc colorizes `df -h` output in all three shells
- [ ] grc colorizes `docker ps` output in all three shells
- [ ] `cat` still uses `bat` (not grc wrapper)
- [ ] `ps` still uses `procs` (not grc wrapper)
- [ ] `ls` still uses `eza` (not grc wrapper)
- [ ] Integration loads silently when grc is not installed
- [ ] Integration works on both Apple Silicon and Intel Macs
- [ ] Integration skips non-interactive shells (scripts)

### Non-Functional Requirements

- [ ] Shell startup time increase < 50ms
- [ ] No error messages when grc is not installed
- [ ] Follows existing conf.d patterns exactly

## Success Metrics

- All colorized commands produce ANSI-colored output in TTY
- No conflicts with existing tool aliases
- Zero startup errors in any shell

## Dependencies & Prerequisites

**Required:**

- `brew install grc` (user must install)
- Homebrew installed at standard location

**No changes needed to:**

- `install-shell-config.sh` script
- Other conf.d files

## Risk Analysis & Mitigation

| Risk                             | Likelihood | Impact | Mitigation                                             |
| -------------------------------- | ---------- | ------ | ------------------------------------------------------ |
| Alias conflict discovered later  | Medium     | Low    | Use `unalias`/`unfunction` pattern to remove conflicts |
| grc output breaks piped commands | Low        | Medium | grc has built-in TTY detection                         |
| User wants disabled command      | Low        | Low    | Document how to customize grc_plugin_execs             |
| Performance impact               | Low        | Low    | grc adds minimal overhead (<5ms per command)           |

## Future Considerations

- Add user preference file (`~/.grc-preferences`) for command customization
- Add environment variable to disable (`DISABLE_GRC=1`)
- Consider adding grc to Brewfile in install scripts

## References & Research

### Internal References

- Existing tool integration pattern: `.claude/skills/rr-system/assets/shell-config/bash/conf.d/86-additional-tools.bash`
- Homebrew prefix detection: `.claude/skills/rr-system/assets/shell-config/bash/conf.d/00-homebrew.bash`
- Conflict: `procs` alias for `ps`: `86-additional-tools.bash:31-35`
- Conflict: `bat` alias for `cat`: `86-additional-tools.bash:63-68`

### External References

- grc GitHub: https://github.com/garabik/grc
- grc Homebrew formula: https://formulae.brew.sh/formula/grc
- grc.sh (Bash): https://github.com/garabik/grc/blob/master/grc.sh
- grc.zsh (Zsh): https://github.com/garabik/grc/blob/master/grc.zsh
- grc.fish (Fish): https://github.com/garabik/grc/blob/master/grc.fish

### Commands Colorized by grc

Full list from grc source (excluding our conflicts):

```
cvs, df, dig, gcc, g++, ifconfig, make, mount, mtr, netstat, ping, tail,
traceroute, wdiff, blkid, du, dnf, docker, docker-compose, docker-machine,
env, id, ip, iostat, journalctl, kubectl, last, lsattr, lsblk, lspci, lsmod,
lsof, getfacl, getsebool, ulimit, uptime, nmap, fdisk, findmnt, free,
semanage, sar, ss, sysctl, systemctl, stat, showmount, tcpdump, tune2fs,
vmstat, w, who, sockstat
```

## MVP Implementation Files

### 86-grc.bash

```bash
#!/usr/bin/env bash
# grc (Generic Colourizer) integration
# Colorizes output of common CLI tools (ping, df, dig, netstat, etc.)
# Install: brew install grc
# https://github.com/garabik/grc

# Skip if grc not installed
command -v grc &> /dev/null || return 0

# Skip if not interactive terminal
[[ $- != *i* ]] && return 0
[[ -z "$TERM" || "$TERM" = "dumb" ]] && return 0

# Detect Homebrew prefix (Apple Silicon vs Intel)
if [[ -d "/opt/homebrew" ]]; then
  _grc_prefix="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  _grc_prefix="/usr/local"
else
  return 0
fi

# Source grc shell integration if it exists
_grc_sh="${_grc_prefix}/etc/grc.sh"
if [[ -f "$_grc_sh" ]]; then
  export GRC_ALIASES=true
  source "$_grc_sh"

  # Remove aliases that conflict with our preferred tools
  unalias cat 2>/dev/null   # Prefer bat
  unalias ps 2>/dev/null    # Prefer procs
  unalias ls 2>/dev/null    # Prefer eza
  unalias diff 2>/dev/null  # Prefer delta
fi

unset _grc_prefix _grc_sh
```

### 86-grc.zsh

```zsh
#!/usr/bin/env zsh
# grc (Generic Colourizer) integration
# Colorizes output of common CLI tools (ping, df, dig, netstat, etc.)
# Install: brew install grc
# https://github.com/garabik/grc

# Skip if grc not installed
(( $+commands[grc] )) || return 0

# Skip if not interactive terminal
[[ -o interactive ]] || return 0
[[ -n "$TERM" && "$TERM" != "dumb" ]] || return 0

# Detect Homebrew prefix (Apple Silicon vs Intel)
local _grc_prefix
if [[ -d "/opt/homebrew" ]]; then
  _grc_prefix="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  _grc_prefix="/usr/local"
else
  return 0
fi

# Source grc shell integration if it exists
local _grc_zsh="${_grc_prefix}/etc/grc.zsh"
if [[ -f "$_grc_zsh" ]]; then
  source "$_grc_zsh"

  # Remove functions that conflict with our preferred tools
  # grc.zsh creates wrapper functions, not aliases
  unfunction cat 2>/dev/null   # Prefer bat
  unfunction ps 2>/dev/null    # Prefer procs
  unfunction ls 2>/dev/null    # Prefer eza
  unfunction diff 2>/dev/null  # Prefer delta
fi
```

### 86-grc.fish

```fish
#!/usr/bin/env fish
# grc (Generic Colourizer) integration
# Colorizes output of common CLI tools (ping, df, dig, netstat, etc.)
# Install: brew install grc
# https://github.com/garabik/grc

# Skip if grc not installed
type -q grc; or exit 0

# Skip if not interactive terminal
status is-interactive; or exit 0

# Detect Homebrew prefix (Apple Silicon vs Intel)
set -l _grc_prefix
if test -d "/opt/homebrew"
    set _grc_prefix "/opt/homebrew"
else if test -d "/usr/local/Homebrew"
    set _grc_prefix "/usr/local"
else
    exit 0
end

# Source grc shell integration if it exists
set -l _grc_fish "$_grc_prefix/etc/grc.fish"
if test -f "$_grc_fish"
    # Override default command list to exclude conflicting tools
    # Excluded: cat (bat), ps (procs), ls (eza), diff (delta)
    set -g grc_plugin_execs cvs df dig gcc g++ ifconfig \
        make mount mtr netstat ping tail traceroute \
        wdiff blkid du dnf docker docker-compose docker-machine env id ip iostat journalctl kubectl \
        last lsattr lsblk lspci lsmod lsof getfacl getsebool ulimit uptime nmap \
        fdisk findmnt free semanage sar ss sysctl systemctl stat showmount \
        tcpdump tune2fs vmstat w who sockstat

    source "$_grc_fish"
end
```

## Documentation Updates

Update `.claude/skills/rr-system/assets/shell-config/README.md` to add grc to the "Modern Tools Referenced" section:

```markdown
- `grc` - Generic colourizer for CLI output (ping, df, dig, netstat, etc.)
```
