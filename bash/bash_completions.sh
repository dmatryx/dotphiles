################################################################################
## Any autocomplete references, programs, and such
################################################################################

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Completion for the U tool
. <(u completion bash)

if [ -f ~/git-prompt.sh ]; then
    . ~/git-prompt.sh
fi

# Completion for jump and unmark
complete -F _completemarks jump unmark

# Load ASDF completions
. ~/.asdf/completions/asdf.bash

[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash

# Load fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# fzf over bash complete
if [ -f ~/code/other/fzf-obc/bin/fzf-obc.bash ]; then
    . ~/code/other/fzf-obc/bin/fzf-obc.bash;
fi
