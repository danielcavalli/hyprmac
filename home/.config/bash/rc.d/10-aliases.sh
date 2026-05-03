if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first --git'
  alias la='eza -a --group-directories-first'
else
  alias ls='ls -G'
  alias ll='ls -lah'
  alias la='ls -A'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias g='git'
alias gs='git status --short'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --decorate --graph --all'
alias reload='hyprmac reload'
alias update='hyprmac update'
alias doctor='hyprmac doctor'
alias ports='hyprmac ports'
