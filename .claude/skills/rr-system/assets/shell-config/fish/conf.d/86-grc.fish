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
