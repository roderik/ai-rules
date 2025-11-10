# Git Worktree Management 🌿
# Professional git worktree management for parallel development workflows
#
# INSTALLATION (Recommended):
# Install as a separate Fish function file from GitHub repository:
#
#   mkdir -p ~/.config/fish/functions && curl -s https://raw.githubusercontent.com/roderik/wt/main/wt.fish > ~/.config/fish/functions/wt.fish && source ~/.config/fish/config.fish
#
# ALTERNATIVE INSTALLATION:
# You can also add this function directly to your Fish configuration file,
# but the separate file approach is cleaner and more maintainable.
#
# USAGE:
#   wt new <branch> [--from <ref>] [--claude|--cursor|--opencode|--all|--none]
#                                   - Create worktree
#   wt switch <branch>              - Switch to existing worktree
#   wt list                         - List all worktrees with status
#   wt clean [--all]                - Clean up worktrees (--all includes non-.worktrees)
#   wt remove <branch>              - Remove specific worktree
#   wt status                       - Show current worktree status
#   wt help                         - Show detailed help
#   wt --claude                     - Launch Claude Code editor
#   wt --cursor                     - Launch Cursor editor
#   wt --opencode                   - Launch OpenCode editor
#   wt --all                        - Launch all editors
#
# EXAMPLES:
#   wt new feature-auth             # Create from default branch
#   wt new hotfix --from v1.0.0     # Create from specific tag
#   wt new api-fix --claude         # Create worktree and launch Claude
#   wt new ui-update --opencode     # Create worktree and launch OpenCode
#   wt new api-docs --all           # Create worktree and launch all editors
#   wt switch feature-auth          # Switch to worktree
#   wt remove api-fix               # Remove specific worktree
#   wt status                       # Show current status
#
# REPOSITORY: https://github.com/roderik/wt

function wt --description "Git worktree management"
    # Check if we have any arguments
    if test (count $argv) -eq 0
        _wt_help
        return 1
    end

    set subcommand $argv[1]
    set remaining_args $argv[2..-1]

    switch $subcommand
        case new
            _wt_new $remaining_args
        case switch s
            _wt_switch $remaining_args
        case list ls
            _wt_list $remaining_args
        case clean
            _wt_clean $remaining_args
        case remove rm
            _wt_remove $remaining_args
        case status st
            _wt_status
        case help h
            _wt_help
        case --claude
            # Launch Claude with dangerously skip permissions
            echo "Launching Claude Code..."
            env SHELL=(which fish) claude --dangerously-skip-permissions
        case --cursor
            # Launch Cursor in current directory
            echo "Launching Cursor..."
            env SHELL=(which fish) cursor .
        case --opencode
            # Launch OpenCode in current directory
            echo "Launching OpenCode..."
            env SHELL=(which fish) opencode .
        case --all
            # Launch all editors - Cursor first (UI), then OpenCode (UI), then Claude (terminal)
            echo "Launching Cursor..."
            env SHELL=(which fish) cursor .
            echo "Launching OpenCode..."
            env SHELL=(which fish) opencode .
            echo "Launching Claude Code..."
            env SHELL=(which fish) claude --dangerously-skip-permissions
        case '*'
            echo "Error: Unknown subcommand '$subcommand'"
            echo "Run 'wt help' for usage information"
            return 1
    end
end

function _wt_help --description "Show wt help information"
    echo "🌿 Git Worktree Manager"
    echo ""
    echo "USAGE:"
    echo "  wt <subcommand> [arguments]"
    echo ""
    echo "SUBCOMMANDS:"
    echo "  new <branch> [options]       Create new worktree"
    echo "    --from <ref>               Base worktree on ref (default: main/master)"
    echo "    --claude                   Launch Claude Code after creation"
    echo "    --cursor                   Launch Cursor after creation"
    echo "    --opencode                 Launch OpenCode after creation"
    echo "    --all                      Launch all editors after creation"
    echo "    --none                     Don't launch any editor"
    echo "  switch, s <branch>           Switch to existing worktree"
    echo "  list, ls                     List all worktrees with status"
    echo "  clean [--all]                Clean up worktrees (--all includes all)"
    echo "  remove, rm <branch>          Remove specific worktree"
    echo "  status, st                   Show current worktree status"
    echo "  help, h                      Show this help message"
    echo ""
    echo "EDITOR OPTIONS:"
    echo "  --claude                     Launch Claude Code (with --dangerously-skip-permissions)"
    echo "  --cursor                     Launch Cursor in current directory"
    echo "  --opencode                   Launch OpenCode in current directory"
    echo "  --all                        Launch all editors"
    echo ""
    echo "EXAMPLES:"
    echo "  wt new feature-auth          Create from default branch"
    echo "  wt new hotfix --from v1.0.0  Create from specific tag"
    echo "  wt new api-fix --claude      Create worktree and launch Claude Code"
    echo "  wt new ui-update --opencode  Create worktree and launch OpenCode"
    echo "  wt new api-docs --all        Create worktree and launch all editors"
    echo "  wt switch feature-auth       Switch to worktree"
    echo "  wt switch main               Switch back to main branch"
    echo "  wt remove api-fix            Remove specific worktree"
    echo "  wt status                    Show current status"
    echo "  wt --claude                  Launch Claude Code editor"
    echo "  wt --cursor                  Launch Cursor editor"
    echo "  wt --opencode                Launch OpenCode editor"
    echo "  wt --all                     Launch all editors"
    echo ""
    echo "TIPS:"
    echo "  • Worktrees are created in ~/.wt/\$(basename \$repo_root)/ directory"
    echo "  • Each worktree has its own node_modules"
    echo "  • Use 'wt clean' to remove all worktrees safely"
end

function _wt_get_repo_root --description "Get the repository root consistently"
    # Try to get the common git directory
    set git_common_dir (git rev-parse --git-common-dir 2>/dev/null)
    if test $status -eq 0
        # If we got a common dir, the repo root is its parent
        if string match -q "*/.git" $git_common_dir
            echo (realpath (dirname $git_common_dir))
            return 0
        end
    end

    # Fallback to show-toplevel
    set toplevel (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -eq 0
        # If we're in a worktree, go up to find the main repo
        if test -f "$toplevel/.git"
            # .git is a file in worktrees, read it to find the real git dir
            set gitfile_content (cat "$toplevel/.git")
            if string match -q "gitdir: *" $gitfile_content
                set git_dir (string replace "gitdir: " "" $gitfile_content)
                # Extract main repo path from worktree git dir
                if string match -q "*/.git/worktrees/*" $git_dir
                    echo (realpath (string replace -r "/.git/worktrees/.*" "" $git_dir))
                    return 0
                end
            end
        else
            echo (realpath $toplevel)
            return 0
        end
    end

    return 1
end

function _wt_get_repo_name --description "Get repository name from repo root"
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        return 1
    end

    # Extract repository name from path
    echo (basename $repo_root)
end

function _wt_new --description "Create new worktree"
    if test (count $argv) -eq 0
        echo "Usage: wt new <branch> [--from <ref>] [--claude|--cursor|--opencode|--all|--none]"
        return 1
    end

    set branch_name $argv[1]

    # Parse optional arguments
    set from_ref ""
    set launch_claude false
    set launch_cursor false
    set launch_opencode false
    set launch_none false

    set i 2
    while test $i -le (count $argv)
        switch $argv[$i]
            case --from
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set from_ref $argv[$i]
                else
                    echo "Error: --from requires a ref argument"
                    return 1
                end
                # Skip the extra increment at the bottom of the loop
                set i (math $i + 1)
                continue
            case --claude
                set launch_claude true
                set launch_cursor false
                set launch_opencode false
                set launch_none false
            case --cursor
                set launch_cursor true
                set launch_claude false
                set launch_opencode false
                set launch_none false
            case --opencode
                set launch_opencode true
                set launch_claude false
                set launch_cursor false
                set launch_none false
            case --all
                set launch_claude true
                set launch_cursor true
                set launch_opencode true
                set launch_none false
            case --none
                set launch_none true
                set launch_claude false
                set launch_cursor false
                set launch_opencode false
        end
        set i (math $i + 1)
    end

    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get repository root
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not determine repository root"
        return 1
    end

    # Validate branch name format
    if string match -q "*/*" $branch_name; or string match -q "* *" $branch_name
        echo "Error: Branch name should not contain slashes or spaces"
        return 1
    end

    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/$branch_name
        echo "Error: Branch '$branch_name' already exists"
        echo "Tip: Use 'wt switch $branch_name' to switch to it"
        return 1
    end

    # Fetch latest changes from origin
    echo "Fetching latest changes from origin..."
    if not git fetch origin >/dev/null 2>&1
        echo "⚠️  Warning: Could not fetch from origin, continuing with local state"
    else
        echo "✅ Fetched latest changes from origin"
    end

    # If no --from was specified, determine the default branch after fetch
    if test -z "$from_ref"
        # Try to get the default branch from remote HEAD
        set remote_head (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)
        if test -n "$remote_head"
            # Extract the branch name from refs/remotes/origin/HEAD -> refs/remotes/origin/main
            set from_ref (string replace "refs/remotes/" "" $remote_head)
        else if git show-ref --verify --quiet refs/heads/main
            set from_ref main
        else if git show-ref --verify --quiet refs/heads/master
            set from_ref master
        else
            # Fallback to current HEAD
            set from_ref HEAD
        end
    end

    # Verify the from ref exists
    if not git rev-parse --verify $from_ref >/dev/null 2>&1
        echo "Error: Reference '$from_ref' does not exist"
        return 1
    end

    # Get repository name for the worktree path
    set repo_name (_wt_get_repo_name)
    if test $status -ne 0
        echo "Error: Could not determine repository name"
        return 1
    end

    # Create worktrees directory in ~/.wt/<repo_name> if it doesn't exist
    set worktree_base_dir "$HOME/.wt/$repo_name"
    if not test -d "$worktree_base_dir"
        mkdir -p -- "$worktree_base_dir"
        echo "Created worktrees directory: $worktree_base_dir"
    end

    set worktree_path "$worktree_base_dir/$branch_name"

    # Check if worktree path already exists
    if test -d "$worktree_path"
        echo "Error: Worktree directory already exists: $worktree_path"
        return 1
    end

    # Create the worktree with the new branch from specified ref
    echo "Creating worktree from '$from_ref'..."
    if git worktree add -b "$branch_name" "$worktree_path" "$from_ref"
        echo "✅ Successfully created worktree and branch '$branch_name'"
        echo "📍 Based on: $from_ref"
        echo "Switching to worktree directory..."
        cd "$worktree_path"
        echo "📁 Location: "(pwd)
        echo "🌿 Branch: "(git branch --show-current)

        # Set up branch to track its own remote branch
        echo "Setting up remote tracking..."
        # Check if the remote branch exists
        if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"
            # Remote branch exists, set it as upstream
            if git branch --set-upstream-to="origin/$branch_name" "$branch_name"
                echo "✅ Branch will push to origin/$branch_name"
            else
                echo "⚠️  Warning: Failed to set upstream tracking for $branch_name"
            end
        else
            # Remote branch doesn't exist yet, configure push behavior
            git config "branch.$branch_name.remote" origin
            git config "branch.$branch_name.merge" "refs/heads/$branch_name"
            echo "✅ Branch configured to push to origin/$branch_name (will create remote branch on first push)"
        end

        # Check for package manager files and run install
        if test -f "package.json"
            echo ""
            if test -f "bun.lock" -o -f "bun.lockb" -o -f "bunfig.toml"
                echo "📦 Running bun install..."
                if bun install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: bun install failed"
                end
            else if test -f "package-lock.json"
                echo "📦 Running npm install..."
                if npm install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: npm install failed"
                end
            else if test -f "yarn.lock"
                echo "📦 Running yarn install..."
                if yarn install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: yarn install failed"
                end
            else if test -f "pnpm-lock.yaml"
                echo "📦 Running pnpm install..."
                if pnpm install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: pnpm install failed"
                end
            else
                echo "📦 Running bun install (default)..."
                if bun install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: bun install failed"
                end
            end
        end

        # Launch editors based on options
        if test $launch_none = false
            if test $launch_cursor = true -o $launch_opencode = true -o $launch_claude = true
                # Launch selected editors
                echo ""
                if test $launch_cursor = true
                    echo "Launching Cursor..."
                    env SHELL=(which fish) cursor .
                end
                if test $launch_opencode = true
                    echo "Launching OpenCode..."
                    env SHELL=(which fish) opencode .
                end
                if test $launch_claude = true
                    echo "Launching Claude Code..."
                    env SHELL=(which fish) claude --dangerously-skip-permissions
                end
            end
        end
    else
        echo "Error: Failed to create worktree"
        return 1
    end
end

function _wt_switch --description "Switch to existing worktree"
    if test (count $argv) -eq 0
        echo "Usage: wt switch <branch>"
        return 1
    end

    set branch_name $argv[1]

    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get repository root
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not find git repository root"
        return 1
    end

    # Special handling for default branches (main/master)
    if test "$branch_name" = main -o "$branch_name" = master
        cd "$repo_root"
        # Try to checkout the requested branch
        if git checkout "$branch_name" --quiet 2>/dev/null
            echo "✅ Switched to main repository"
            echo "📁 Location: "(pwd)
            echo "🌿 Branch: "(git branch --show-current)

            # Show brief status
            set modified_count (git status --porcelain | wc -l | string trim)
            if test $modified_count -gt 0
                echo "📝 Modified files: $modified_count"
            end
            return 0
        else
            echo "Error: Branch '$branch_name' does not exist in main repository"
            return 1
        end
    end

    # Get repository name for the worktree path
    set repo_name (_wt_get_repo_name)
    if test $status -ne 0
        echo "Error: Could not determine repository name"
        return 1
    end

    set worktree_path "$HOME/.wt/$repo_name/$branch_name"

    if test -d "$worktree_path"
        cd "$worktree_path"
        echo "✅ Switched to worktree: $branch_name"
        echo "📁 Location: "(pwd)
        echo "🌿 Branch: "(git branch --show-current)

        # Show brief status
        set modified_count (git status --porcelain | wc -l | string trim)
        if test $modified_count -gt 0
            echo "📝 Modified files: $modified_count"
        end
    else
        echo "Error: Worktree not found: $worktree_path"
        echo ""
        echo "Available worktrees:"
        _wt_list
        return 1
    end
end

function _wt_list --description "List all git worktrees"
    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    echo "📋 Git Worktrees:"
    echo ""

    # Get current directory to highlight current worktree
    set current_dir (pwd)

    # Parse git worktree list output for better formatting
    set worktree_info (git worktree list --porcelain)
    set current_path ""
    set current_branch ""
    set current_commit ""

    for line in $worktree_info
        if string match -q "worktree *" $line
            set current_path (string sub -s 10 $line)
        else if string match -q "HEAD *" $line
            set current_commit (string sub -s 6 $line | string sub -l 7)
        else if string match -q "branch *" $line
            set current_branch (string sub -s 8 $line | string replace "refs/heads/" "")
        else if test -z "$line"
            # Empty line means end of current worktree info
            if test -n "$current_path"
                # Check if this is the current worktree
                if test "$current_dir" = "$current_path"
                    echo -n "→ "
                else
                    echo -n "  "
                end

                # Format the output
                # Get repository root and name to check if this is a worktree
                set repo_root (_wt_get_repo_root)
                if test $status -eq 0
                    set repo_name (_wt_get_repo_name)
                    if test $status -eq 0
                        # Check if this path is under ~/.wt/<repo_name>/
                        if string match -q "$HOME/.wt/$repo_name/*" "$current_path"
                            set display_path (basename $current_path)
                            echo -n "🌿 $current_branch"
                        else
                            set display_path main
                            echo -n "🏠 $current_branch"
                        end
                    else
                        # Fallback if repo name cannot be determined
                        echo -n "📍 $current_branch"
                    end
                else
                    # Fallback if repo root cannot be determined
                    echo -n "📍 $current_branch"
                end

                echo " ($current_commit) - $current_path"

                # Reset for next worktree
                set current_path ""
                set current_branch ""
                set current_commit ""
            end
        end
    end
end

function _wt_status --description "Show current worktree status"
    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    echo "📊 Current Worktree Status:"
    echo ""

    # Get current worktree info
    set current_branch (git branch --show-current)
    set current_dir (pwd)

    echo "📁 Location: $current_dir"
    echo "🌿 Branch: $current_branch"

    # Check if we're in a worktree or main repo
    # Get repository root to check if this is a worktree
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not determine repository root"
        return 1
    end

    # Get repository name to check if we're in a worktree
    set repo_name (_wt_get_repo_name)
    if test $status -eq 0
        # Check if current directory is under ~/.wt/<repo_name>/
        if string match -q "$HOME/.wt/$repo_name/*" "$current_dir"
            echo "📍 Type: Worktree"
        else
            echo "📍 Type: Main repository"
        end
    else
        # Default to main repository if repo name cannot be determined
        echo "📍 Type: Main repository"
    end

    # Show git status summary
    echo ""
    set modified_count (git diff --name-only | wc -l | string trim)
    set staged_count (git diff --cached --name-only | wc -l | string trim)
    set untracked_count (git ls-files --others --exclude-standard | wc -l | string trim)

    echo "📝 Changes:"
    echo "  • Staged: $staged_count files"
    echo "  • Modified: $modified_count files"
    echo "  • Untracked: $untracked_count files"

    # Show ahead/behind status
    set upstream (git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if test -n "$upstream"
        set ahead_behind (git rev-list --left-right --count $upstream...HEAD 2>/dev/null)
        if test -n "$ahead_behind"
            set behind (echo $ahead_behind | cut -f1)
            set ahead (echo $ahead_behind | cut -f2)
            echo ""
            echo "📊 Upstream: $upstream"
            echo "  • Ahead: $ahead commits"
            echo "  • Behind: $behind commits"
        end
    end
end

function _wt_remove --description "Remove specific worktree"
    if test (count $argv) -eq 0
        echo "Usage: wt remove <branch>"
        return 1
    end

    set branch_name $argv[1]

    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get repository root
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not find git repository root"
        return 1
    end

    # Get repository name for the worktree path
    set repo_name (_wt_get_repo_name)
    if test $status -ne 0
        echo "Error: Could not determine repository name"
        return 1
    end

    set worktree_path "$HOME/.wt/$repo_name/$branch_name"

    if not test -d "$worktree_path"
        echo "Error: Worktree not found: $worktree_path"
        return 1
    end

    # Check if we're currently in the worktree we're trying to remove
    set current_dir (pwd)
    if test "$current_dir" = "$worktree_path"
        echo "⚠️  You are currently in the worktree you want to remove"
        echo "📍 Switching to main repository first..."

        # Switch to main repository
        cd "$repo_root"
        if test $status -ne 0
            echo "❌ Failed to switch to main repository"
            return 1
        end
        echo "✅ Switched to main repository"
    end

    # Confirm removal
    echo "About to remove worktree:"
    echo "  📁 Path: $worktree_path"
    echo "  🌿 Branch: $branch_name"

    read -l -P "Remove this worktree? [y/N]: " confirmation

    if test "$confirmation" = y; or test "$confirmation" = Y
        if git worktree remove "$worktree_path" --force
            echo "✅ Successfully removed worktree: $branch_name"

            # Ask if they want to delete the branch too
            read -l -P "Also delete the branch '$branch_name'? [y/N]: " delete_branch
            if test "$delete_branch" = y; or test "$delete_branch" = Y
                if git branch -D "$branch_name"
                    echo "✅ Successfully deleted branch: $branch_name"
                else
                    echo "⚠️  Failed to delete branch: $branch_name"
                end
            end
        else
            echo "❌ Failed to remove worktree"
            return 1
        end
    else
        echo "Removal cancelled"
    end
end

function _wt_clean --description "Clean up all git worktrees"
    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get repository root
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not determine repository root"
        return 1
    end

    # Normalize repo root path
    set repo_root_normalized (realpath $repo_root 2>/dev/null || echo $repo_root)

    # Check for --all flag
    set include_all 0
    if contains -- --all $argv
        set include_all 1
    end

    # Get list of worktrees
    set worktree_info (git worktree list --porcelain)
    set worktrees_to_remove

    # Parse worktree info to get worktree paths
    for line in $worktree_info
        if string match -q "worktree *" $line
            set current_worktree (string sub -s 10 $line)
            set current_worktree_normalized (realpath $current_worktree 2>/dev/null || echo $current_worktree)

            # Include worktrees based on flag
            if test $include_all -eq 1
                # Include all worktrees except the main one
                if test "$current_worktree_normalized" != "$repo_root_normalized"
                    set worktrees_to_remove $worktrees_to_remove $current_worktree
                end
            else
                # Only include worktrees in ~/.wt/<repo_name>/ directory
                # Get repository name to check worktree location
                set repo_name (_wt_get_repo_name)
                if test $status -eq 0
                    set worktrees_dir "$HOME/.wt/$repo_name"
                    if string match -q "$worktrees_dir/*" "$current_worktree"
                        set worktrees_to_remove $worktrees_to_remove $current_worktree
                    end
                end
            end
        end
    end

    if test (count $worktrees_to_remove) -eq 0
        echo "No worktrees found to clean up"
        if test $include_all -eq 0
            echo "Tip: Use 'wt clean --all' to include all worktrees"
        end
        return 0
    end

    echo "Found "(count $worktrees_to_remove)" worktree(s) to remove:"
    for worktree in $worktrees_to_remove
        echo "  📁 $worktree"
    end

    # Confirm before deletion
    read -l -P "Remove all these worktrees? [y/N]: " confirmation

    if test "$confirmation" = y; or test "$confirmation" = Y
        set removed_count 0
        set failed_count 0

        for worktree in $worktrees_to_remove
            echo "Removing worktree: $worktree"
            if git worktree remove $worktree --force
                echo "✅ Removed worktree: $worktree"
                set removed_count (math $removed_count + 1)
            else
                echo "⚠️  Failed to remove worktree: $worktree"
                set failed_count (math $failed_count + 1)
            end
        end

        echo ""
        echo "Summary:"
        echo "  ✅ Successfully removed: $removed_count worktree(s)"
        if test $failed_count -gt 0
            echo "  ❌ Failed to remove: $failed_count worktree(s)"
        end

        # Always navigate back to repository root after cleaning
        echo ""
        echo "📁 Returning to repository root: $repo_root"
        cd "$repo_root"
    else
        echo "Cleanup cancelled"
    end
end

# Add completion support
complete -c wt -f
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a new -d "Create new worktree"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a "switch s" -d "Switch to worktree"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a "list ls" -d "List worktrees"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a clean -d "Clean up worktrees"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a "remove rm" -d "Remove worktree"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a "status st" -d "Show status"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a "help h" -d "Show help"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a --claude -d "Launch Claude Code"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a --cursor -d "Launch Cursor"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a --opencode -d "Launch OpenCode"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h --claude --cursor --opencode --all" -a --all -d "Launch all editors"

# Complete branch names for switch and remove commands
complete -c wt -n "__fish_seen_subcommand_from switch s remove rm" -a "(git branch --format='%(refname:short)')"
complete -c wt -n "__fish_seen_subcommand_from new" -l from -d "Create from specific ref"
complete -c wt -n "__fish_seen_subcommand_from clean" -l all -d "Include all worktrees"
