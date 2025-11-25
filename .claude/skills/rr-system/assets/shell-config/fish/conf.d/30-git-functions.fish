# Git Functions
# Custom git utilities and helper functions

function gclean --description 'Remove local branches that have been merged'
    git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d
end

function gbda --description 'Delete all branches that have been merged into main/master'
    git branch --no-color --merged | command grep -vE "^([+*]|\s*(main|master|develop|dev)\s*\$)" | command xargs git branch -d 2>/dev/null
end

function gfg --description 'Fuzzy find and checkout git branch'
    if not command -q fzf
        echo "fzf is required for this function"
        return 1
    end

    set -l branch (git branch -a | grep -v HEAD | string trim | fzf --height 20% --reverse --info=inline)
    if test -n "$branch"
        # Use fish string manipulation instead of sed
        set branch (string replace -r '^\s*\*?\s*' '' $branch)
        set branch (string replace -r '^remotes/[^/]+/' '' $branch)
        git checkout $branch
    end
end

function glog --description 'Pretty git log with graph'
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
end

function glogf --description 'Interactive git log with fzf'
    if not command -q fzf
        echo "fzf is required for this function"
        return 1
    end

    git log --oneline --decorate --color=always | \
        fzf --ansi --no-sort --reverse \
            --preview 'git show --color=always {1}' \
            --bind 'enter:execute(git show --color=always {1} | less -R)+abort'
end

function gdm --description 'Delete all local branches except main/master (force delete)'
    set -l current_branch (git branch --show-current)
    set -l protected_branches "main" "master"

    # Check if we're on a branch that will be deleted
    if not contains $current_branch $protected_branches
        echo "Switching to main/master first..."
        if git show-ref --verify --quiet refs/heads/main
            git checkout main
        else if git show-ref --verify --quiet refs/heads/master
            git checkout master
        else
            echo "Error: Neither main nor master branch exists"
            return 1
        end
    end

    # Delete all branches except protected ones (using fish string instead of sed)
    set -l branches_to_delete (git branch | string replace -r '^\s*\*?\s*' '' | string match -v 'main' | string match -v 'master')
    if test (count $branches_to_delete) -gt 0
        for branch in $branches_to_delete
            git branch -D $branch
        end
        echo "Deleted branches: $branches_to_delete"
    else
        echo "No branches to delete"
    end
end