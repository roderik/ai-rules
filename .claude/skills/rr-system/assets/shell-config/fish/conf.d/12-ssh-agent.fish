# SSH Agent configuration
# Auto-start ssh-agent and persist socket across sessions

if status is-interactive
    set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"

    # Start agent if socket doesn't exist or agent isn't responding
    if not ssh-add -l &>/dev/null
        rm -f $SSH_AUTH_SOCK
        ssh-agent -a $SSH_AUTH_SOCK &>/dev/null
    end
end
