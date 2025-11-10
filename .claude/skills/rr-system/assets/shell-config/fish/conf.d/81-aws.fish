#!/usr/bin/env fish
# AWS CLI completion

# Enable AWS CLI completion if available
if type -q aws_completer
    complete -c aws -f -a '(env COMP_LINE=(commandline -cp) aws_completer)'
end