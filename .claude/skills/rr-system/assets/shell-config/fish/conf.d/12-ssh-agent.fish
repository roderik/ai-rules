# SSH Agent configuration
# Auto-start ssh-agent and persist socket across sessions

if status is-interactive
    set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"

    # Start agent only if socket doesn't exist (faster than ssh-add -l check)
    if not test -S "$SSH_AUTH_SOCK"
        rm -f $SSH_AUTH_SOCK
        ssh-agent -a $SSH_AUTH_SOCK &>/dev/null
    end
end
