################################################################################
## Environment specific things.
################################################################################

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDSTATE=1
export GIT_PS1_SHOWUPSTREAM="verbose"
export GIT_PS1_STATESEPARATOR=''
export GIT_PS1_DESCRIBESTYLE="describe"

__set_bash_prompt()
{
  local exit="$?"

  export GIT_PS1_SHOWCOLORHINTS=0

  local None='\[\e[0m\]'
  local Green='\[\e[92m\]'
  local BRed='\[\e[1;31m\]'
  local Red='\[\e[31m\]'
  local Yellow='\[\e[93m\]'
  local Cyan='\[\e[96m\]'

  local KubeBlue='\[\e[1;34m\]'
  local KubeBlack='\[\e[1;30m\]'
  local KubeRed='\[\e[1;31m\]'

  # Start with the window title in pre-prompt.
  local PrePrompt='${debian_chroot:+($debian_chroot)}\[\e]0;\u$([ "${HOSTNAME}" != "greg-thinkpad" ] && printf "@\h";):$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~"; printf "${p//[^[:ascii:]]/?}")    `__git_ps1`\007\]'
  local PostPrompt=""

  KubeNS=$(kubectl config view --minify --output 'jsonpath={..namespace}')
  KubeCluster=$(kubectl config current-context)

  # Prompt construction
  # Debian Chroot display, plus a solitary [ to begin the line....
  PrePrompt+="${debian_chroot:+($debian_chroot)}["
  # User / Host (aware of root)
  if [[ ${EUID} == 0 ]]; then
  #   PrePrompt+="$BRed\h "
    PrePrompt+="$BRed\u|"
  # else
  #   PrePrompt+="$Green\u@\h "
  fi

  # Kubernetes Bits
  if [ "$KubeCluster" = "black" ] ; then
    PrePrompt+="$KubeBlack"
  elif [ "$KubeCluster" = "blue" ] ; then
    PrePrompt+="$KubeBlue"
  elif [ "$KubeCluster" = "red" ] ; then
    PrePrompt+="$KubeRed"
  fi
  PrePrompt+="$KubeCluster"
  PrePrompt+="$None $Green$KubeNS"
  PrePrompt+="$None "

  # Working Directory
  PrePrompt+="$Yellow\W"
  # End the ] for the left side.
  PrePrompt+="$None] "

  if [[ $exit != 0 ]]; then
    PostPrompt="$Red[$exit]$None"
  fi

  PostPrompt+='\n$ '

  __git_ps1 "$PrePrompt" "$PostPrompt" "(%s)"

#  export PS1='\[\033]0;\u@\h    ${PWD//[^[:ascii:]]/?}    `__git_ps1`\007\][\[\033[92m\]\u@\h \[\033[93m\]\W\[\033[0m\]]\[\033[96m\]`__git_ps1`\[\033[0m\]\n$ '
}

PROMPT_COMMAND="__set_bash_prompt;history -a"

if [ -f /etc/profile.d/golang_path.sh ]; then
    . /etc/profile.d/golang_path.sh
fi

export GOPATH=`go env GOPATH`
export MARKPATH="$HOME/.marks"

PATH="$HOME/scripts:$GOPATH/bin:$PATH"

# Nice manpages. Most is to less as less is to more.
export MANPAGER='most'

# Necessary for a lot of google libraries
export GOOGLE_APPLICATION_CREDENTIALS=application_default_credentials.json
