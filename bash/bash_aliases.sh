################################################################################
## Aliases only please.
################################################################################

# Personal preference and habit
alias vi='vim'

# Pretty print json
alias jqp="jq '.'"

# Load sublime with this current folder, in a new window.
alias ideah='(intellij-idea-ultimate ./ &) > /dev/null 2>&1'

# Do updates and upgrades for installed packages.
alias sapt='sudo apt-get update --fix-missing && sudo apt-get --with-new-pkgs upgrade --fix-missing'

# Kubectl
alias k='kubectl'
alias kl='kubectl logs'
alias lns="kubectl get namespace -l 'prometheus in (customer-platform,ldn,data-engineering)'"

# Git
alias gd='git diff'
alias gds='git diff --staged'
alias gcm='git checkout master'
alias gs='git status'
alias ga='git add'
alias gr='git rm'
alias gc='git commit'

#alias screen='screen -q'

alias bikeshed='staticcheck'
alias gotest='go run gotest.tools/gotestsum@latest --format testdox -- -coverprofile=cover.out ./...'
