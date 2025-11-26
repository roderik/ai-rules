# 1Password CLI configuration
# Cache op completions and patch out the eager `complete --do-complete` call
# that triggers `op __complete` at load time (adds ~70ms to shell startup)

if command -q op
    set -l user_completions ~/.config/fish/completions
    set -l completion_file "$user_completions/op.fish"
    set -l op_path (command -v op)

    # Generate patched completion file that removes eager completion trigger
    if not test -f "$completion_file"; or test "$op_path" -nt "$completion_file"
        mkdir -p "$user_completions"
        # Generate completions and remove the `complete --do-complete` block
        # that causes op __complete to run at shell startup
        op completion fish 2>/dev/null | sed '/^if type -q "op"/,/^end$/d' > "$completion_file"
    end
    # Fish loads from ~/.config/fish/completions/ which takes precedence over vendor completions
end