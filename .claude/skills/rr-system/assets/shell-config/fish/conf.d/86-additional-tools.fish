#!/usr/bin/env fish
# Additional tool configurations

# Lazygit - Terminal UI for git
if type -q lazygit
    alias lg='lazygit'
    alias lzg='lazygit'
end

# Lazydocker - Terminal UI for docker
if type -q lazydocker
    alias lzd='lazydocker'
    alias ld='lazydocker'
end

# Git Delta - Better git diff
if type -q delta
    set -gx GIT_PAGER 'delta'
    set -gx DELTA_PAGER 'less -R'
end

# Broot - Better tree
if type -q broot
    # Broot launcher function
    function br --wraps=broot
        set -l cmd_file (mktemp)
        if broot --outcmd $cmd_file $argv
            source $cmd_file
        end
        rm -f $cmd_file
    end
end

# Procs - Better ps
if type -q procs
    alias ps='procs'
    alias pst='procs --tree'
    alias psw='procs --watch'
end

# Hexyl - Hex viewer
if type -q hexyl
    alias hex='hexyl'
    alias hexdump='hexyl'
end

# Chafa - Terminal graphics viewer
if type -q chafa
    alias img='chafa'
    alias image='chafa'
end

# Ripgrep aliases (better grep)
if type -q rg
    alias rgi='rg -i'  # case insensitive
    alias rgl='rg -l'  # files with matches
    alias rgv='rg -v'  # invert match
end

# fd aliases (better find)
if type -q fd
    alias fdi='fd -i'  # case insensitive
    alias fdh='fd -H'  # include hidden
end

# Bat aliases (better cat)
if type -q bat
    alias cat='bat --style=plain'
    alias catp='bat'  # with style
    set -gx BAT_THEME "base16-256"
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

# Tilt - Local Kubernetes development
if type -q tilt
    alias tu='tilt up'
    alias td='tilt down'
end

# Zellij - Modern terminal multiplexer
if type -q zellij
    alias zj='zellij'
    alias zja='zellij attach'
    alias zjs='zellij session'
    alias zjl='zellij list-sessions'
end

# ast-grep - Structural search/replace
if type -q ast-grep
    alias sg='ast-grep'
    alias sgs='ast-grep search'
    alias sgr='ast-grep replace'
end