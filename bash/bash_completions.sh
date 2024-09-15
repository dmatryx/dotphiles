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

if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
fi

if [ -f ~/git-prompt.sh ]; then
    . ~/git-prompt.sh
fi

# Completion for jump and unmark
complete -F _completemarks jump unmark

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -f ~/code/other/fzf-obc/bin/fzf-obc.bash ]; then
    . ~/code/other/fzf-obc/bin/fzf-obc.bash;
fi

# Load ASDF completions
. ~/.asdf/completions/asdf.bash