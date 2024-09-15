# Setup fzf
# ---------
if [[ ! "$PATH" == */home/greg/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/greg/.fzf/bin"
fi

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    u)            fzf --no-preview ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

_fzf_complete_u() {
  if [[ $3 == "db" ]]; then
    _fzf_complete -- "$@" < <(
      command u vault db-roles 2>/dev/null | sed '1d' | sort -u
    )
  else
    __start_u
  fi
}

[ -n "$BASH" ] && complete -F _fzf_complete_u -o default -o bashdefault u



# Auto-completion
# ---------------
source "/home/greg/.fzf/shell/completion.bash"

# Key bindings
# ------------
source "/home/greg/.fzf/shell/key-bindings.bash"


# usage: _fzf_setup_completion path|dir|var|alias|host COMMANDS...
_fzf_setup_completion path ag kubectl
_fzf_setup_completion dir tree

# export FZF_COMPLETION_OPTS='--border --info=inline'
