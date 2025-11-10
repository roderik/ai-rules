# Fish Abbreviations
# Expand on space - only in interactive sessions

if status is-interactive
    # Git abbreviations
    abbr --add g git
    abbr --add ga 'git add'
    abbr --add gaa 'git add --all'
    abbr --add gap 'git add --patch'
    abbr --add gb 'git branch'
    abbr --add gba 'git branch --all'
    abbr --add gbd 'git branch --delete'
    abbr --add gc 'git commit --verbose'
    abbr --add gca 'git commit --verbose --all'
    abbr --add gcad 'git commit --all --amend'
    abbr --add gcam 'git commit --all --message'
    abbr --add gcm 'git commit --message'
    abbr --add gco 'git checkout'
    abbr --add gcob 'git checkout -b'
    abbr --add gcp 'git cherry-pick'
    abbr --add gd 'git diff'
    abbr --add gds 'git diff --staged'
    abbr --add gf 'git fetch'
    abbr --add gfa 'git fetch --all --prune'
    abbr --add gl 'git pull'
    abbr --add glg 'git log --stat'
    abbr --add glgg 'git log --graph'
    abbr --add glgga 'git log --graph --decorate --all'
    abbr --add glo 'git log --oneline --decorate'
    abbr --add gp 'git push'
    abbr --add gpf 'git push --force-with-lease'
    abbr --add gpr 'git pull --rebase'
    abbr --add gr 'git remote'
    abbr --add gra 'git remote add'
    abbr --add grb 'git rebase'
    abbr --add grbi 'git rebase --interactive'
    abbr --add grh 'git reset HEAD'
    abbr --add grhh 'git reset HEAD --hard'
    abbr --add grs 'git restore'
    abbr --add grss 'git restore --staged'
    abbr --add gs 'git status'
    abbr --add gss 'git status --short'
    abbr --add gst 'git stash'
    abbr --add gsta 'git stash apply'
    abbr --add gstd 'git stash drop'
    abbr --add gstl 'git stash list'
    abbr --add gstp 'git stash pop'
    abbr --add gsts 'git stash show --text'
    abbr --add gsw 'git switch'
    abbr --add gswc 'git switch --create'

    # Directory navigation
    abbr --add ... 'cd ../..'
    abbr --add .... 'cd ../../..'
    abbr --add ..... 'cd ../../../..'

    # Docker abbreviations
    abbr --add d docker
    abbr --add dc 'docker compose'
    abbr --add lzd lazydocker

    # Other tool abbreviations
    abbr --add lzg lazygit
end