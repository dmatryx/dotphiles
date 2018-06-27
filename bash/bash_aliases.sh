################################################################################
## Aliases only please.
################################################################################

# Personal preference and habit
alias vi='vim'

# Pretty print json
alias jqp="jq '.'"

# Load sublime with this current folder, in a new window.
alias sublh='subl -n .'

# Do updates and upgrades for installed packages.
alias sapt='sudo apt-get update && sudo apt-get --with-new-pkgs upgrade'

# Toggle alias to jump between go verion of a repo and the code version.
alias gogo='GOTO=$(pwd | sed "s:$HOME/code/zpg:$HOME/~~/go/src/github.com/uswitch:; s:$HOME/go/src/github.com/uswitch:$HOME/code/zpg:; s:$HOME/~~/:$HOME/:") ; cd $GOTO ; echo -e "Changed to $(colourizePath -d 3 $GOTO)"'
