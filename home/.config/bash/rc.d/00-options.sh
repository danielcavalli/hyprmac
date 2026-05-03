shopt -s checkwinsize
shopt -s histappend
shopt -s cmdhist
shopt -s globstar

export HISTFILE="$HOME/.bash_history"
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
