################################################################################
## Display and utility functions go here
################################################################################

# Shorthand to sync dotfiles over, regardless of where it is run from.
function dotsync {
  (
    cd ~
    ./.dotfiles/dotsync/bin/dotsync -L
  )
}

#export -f dotsync

# colourizePath: [-d n] [-f n] Pathspec
#
# Function to take a pathspec and pretty it up.
# At it's simplest, it just (R-L) colourises depth
# -d n
#   maxDepth will let you stop processing past n levels and leave the rest at
#   the colour of the max depth level.
# -f n
#   forceColour will set everything to one colour. Useful for common pre-paths.
#   forceColour can take a number or a locally declared variable.
# -l n:m
#   lock the left n entries and make them colour m
function colourizePath {

  local OPTIND
  local maxNumber=5
  local forceColour=0
  local shifter=0
  local leftLock=0
  local leftColour=0

  while getopts "d:f:l:" OPTLOOP; do
    case ${OPTLOOP} in
      d)
        maxNumber="${OPTARG}"
        (( shifter++ ))
        (( shifter++ ))
        ;;
      f)
        forceColour="${OPTARG}"
        (( shifter++ ))
        (( shifter++ ))
        ;;
      l)
        presplit="${OPTARG}"
        IFS=':'
        subopts=($presplit)
        unset IFS;
        leftLock=${subopts[0]}
        leftColour=${subopts[1]}
        (( shifter++ ))
        (( shifter++ ))
        ;;
      *)
        ;;
    esac
  done
  shift $shifter

  local C_CYA='\e[36m'
  local C_GRE='\e[32m'
  local C_YEL='\e[93m'
  local C_ORA='\e[91m'
  local C_RED='\e[31m'
  local C_BRO='\e[33m'

  local C_RST='\e[0m'

  local SEP=${C_BRO}/${C_RST}

  pathspec=$1

  [[ "$pathspec" =~ ^"$HOME"(/|$) ]] && pathspec="~${pathspec#$HOME}"
  IFS='/';
  pathParts=($pathspec)
  unset IFS;
  arrayCount=${#pathParts[@]}
  for i in "${!pathParts[@]}"; do
    colourToUse=$[${arrayCount}-${i}];
    if [ $leftLock -gt 0 ]; then
      if [ $i -lt $leftLock  ]; then
        colourToUse=$leftColour
      fi
    fi
    if [ $maxNumber -lt $colourToUse ]; then
      colourToUse=$maxNumber
    fi
    if [ $forceColour != 0 ]; then
      colourToUse=$forceColour
    fi
    if [[ $colourToUse =~ ^[1-5]$ ]]; then
      case ${colourToUse} in
        1)
          echo -en ${C_CYA}
          ;;
        2)
          echo -en ${C_GRE}
          ;;
        3)
          echo -en ${C_YEL}
          ;;
        4)
          echo -en ${C_ORA}
          ;;
        *)
          echo -en ${C_RED}
          ;;
      esac
    else
      echo -en "${!colourToUse}"
    fi
    echo -n ${pathParts[$i]}
    echo -en ${C_RST}
    local POS=$((${arrayCount} - ${i}))
    if [ ${POS} -gt 1 ]; then
      echo -en ${SEP}
    fi
  done
}

# export -f colourizePath



################################################################################
## Git related functions
################################################################################

# This function is a safe fast-forward update for git. Regardless of whether this is your current branch or not.
# It takes two params - the first of which is the local reference to update, the second of which is the pre-detected upstream branch
# If you use this manually, it will reject any FF attempt which is not a fastforward refsec update
# The function will only perform the merge if it knows in advance it will succeed.
function gitSafeFF {
  COUNT=$(git rev-list ${1}..${2} --count)
  if [[ ${COUNT} -eq 0 ]]
  then
    echo -e "\033[33mSkipping\033[0m : '$(colourizePath ${1})' - Up To Date."
  else
    COUNT=$(git rev-list ${2}..${1} --count)
    if [[ ${COUNT} -gt 0 ]]
    then
      echo -e "\033[93mWarning\033[0m  : '$(colourizePath ${1})' - Divergence from remote detected. (Skipping)."
    else
      if [[ "${currentbranch}" == "${1}" ]]
      then
        echo "'${1}' is the current branch. Using pull/merge (FF only) functionality instead..."

        #Checking working copy state for changes
        git diff --no-ext-diff --quiet
        DIRTY=$?
        if [[ $DIRTY -eq 1 ]]
        then
          echo -e "\033[93mWarning\033[0m  : '$(colourizePath ${1})' - Changes detected in working copy. (Skipping)."
          return
        fi

        echo "Testing FF Merge only."
        git merge --ff-only ${2} -n
      else
        echo -e "\033[32mUpdating\033[0m : '$(colourizePath ${1})'"
        git fetch ${2%%/*} ${2#*/}:${1}
      fi
    fi
  fi
}

# export -f gitSafeFF

# This function will either selectively update, or batch update refspecs it can locate.
# Where possible it will fastforward, but it will update in all cases the status of the branch.
function gup {
  currentbranch="$(git rev-parse --abbrev-ref HEAD)"

  for REF in `git remote`
  do
    echo -e "Fetching \e[1;95m${REF}\e[0m"
    git fetch --prune --tags ${REF};
  done

  if [[ $# -eq 0 ]];
  then
    #TODO: Usage.
    echo "No params given. Exiting."
    return
  fi

  if [[ $1 == "all" ]]
  then
    echo "Fast-forwarding all local branches where possible."
    ITERATEREFS="$(git for-each-ref --format='%(refname:short)' refs/heads/)"
    for REF in ${ITERATEREFS}
    do
      UPSTREAM=$(git rev-parse --abbrev-ref ${REF}@{upstream} 2>/dev/null)
      VALID=$?
      if [[ ${VALID} -eq 0 ]]
      then
        gitSafeFF ${REF} ${UPSTREAM}
      else
        # TODO:: Different error code handling?
        POTENTIAL=$(git show-ref "origin/${REF}")
        VALID=$?
        if [[ ${VALID} -eq 0 ]]
        then
          echo -e "\033[93mWarning\033[0m  : '$(colourizePath ${REF})' - No upstream configured for this branch."
          echo -e "\033[32mFound\033[0m    : '$(colourizePath origin/${REF})' - Testing branch compatibility."
          git merge-base --is-ancestor ${REF} origin/${REF}
          VALID=$?
          if [[ ${VALID} -eq 0 ]]
          then
            git branch --set-upstream-to=origin/${REF} ${REF}
            gitSafeFF ${REF} origin/${REF}
          else
            echo -e "\033[93mWarning\033[0m  : '$(colourizePath origin/${REF})' - Unrelated to current branch."
          fi
        else
          git merge-base --is-ancestor ${REF} origin/master
          VALID=$?
          if [[ ${VALID} -eq 0 ]]
          then
            CURBRANCH="$(git symbolic-ref HEAD 2>/dev/null)" || CURBRANCH="(unnamed branch)"
            if [[ "${CURBRANCH##refs/heads/}" == "${REF}" ]]
            then
              echo -e "\033[90mIgnoring\033[0m : '$(colourizePath ${REF})' - Currently checked out branch."
            else
              echo -e "\033[91mCleaning\033[0m : '$(colourizePath ${REF})' - Cleaning up fully merged branch."
              git branch -D ${REF}
            fi
          else
            echo -e "\033[90mIgnoring\033[0m : '$(colourizePath ${REF})' - No upstream configured for this branch."
          fi
        fi
      fi
    done
    return
  else
    echo "Validating Reference"
    git show-ref "${1}" -q
    VALID=$?
    if [[ ${VALID} -eq 1 ]]
    then
      echo -e "\033[91mError\033[0m    : '$(colourizePath ${1})' - Reference not known to repository."
      return
    fi

    echo "Checking Local Refs."
    git show-ref "${localheads}${1}" -q
    VALID=$?
    if [[ ${VALID} -eq 0 ]]
    then
      REF=${1}
      echo "Found at $(colourizePath ${REF})"
      UPSTREAM=$(git rev-parse --abbrev-ref ${REF}@{upstream} 2>/dev/null)
      VALID=$?
      if [[ ${VALID} -eq 0 ]]
      then
        gitSafeFF ${REF} ${UPSTREAM}
      else
        echo -e "\033[90mIgnoring\033[0m : '$(colourizePath ${REF})' - No upstream configured for this branch."
      fi
      return
    fi

    echo -e "\033[91mError\033[0m    : '$(colourizePath ${1})' - Reference given is not a local branch."
  fi
}

# export -f gup

# This is like a mega-version of gup above.
# Set the root directory where all of your code is located and let it go to town.
# Expects a structure optionally 2 levels deep because of current work environment.
function gupp(){
  CODE_DIR="${HOME}/code"
  echo "======================================================"
  echo "Updating All Repositories under $(colourizePath -f C_YEL "${CODE_DIR}")"
  echo "======================================================"
  # Enumerate repos to run
  local LOCATIONS=()
  for ORG in `ls ${CODE_DIR}`; do
    local LOC="${CODE_DIR}/${ORG}"
    if [ -d "${LOC}/.git" ]; then
      LOCATIONS+=(${LOC})
    else
      for REPO in `ls ${CODE_DIR}/${ORG}`; do
        local LOC="${CODE_DIR}/${ORG}/${REPO}"
        if [ -d "${LOC}/.git" ]; then
          LOCATIONS+=(${LOC})
        fi
      done
    fi
  done

  local repocount=${#LOCATIONS[@]}

  for (( i=0; i<${repocount}; i++ ))
  do
    (
      cd "${LOCATIONS[$i]}"
      echo "Now processing [$[i + 1]/${repocount}] >> $(colourizePath -l 2:3 "${LOCATIONS[$i]}")"
      gup all
      echo -e ""
    )
  done
  echo "Done"
}

# export -f gupp

# Marks a folder by creating a symlink inside a predefined area to it.
function mark(){
  if [[ $1 = 'back' ]]; then
    echo "'back' has a special meaning to jump, and cannot be used as a mark.";
  else
    mkdir -p "$MARKPATH";
    ln -s "$(pwd)" "$MARKPATH/$1";
  fi
}

# Jumps to a mark defined from the mark function.
function jump(){
  if [[ $1 = 'back' ]]; then
    cd -P "$OLDPWD" 2> /dev/null;
  else
    cd -P "$MARKPATH/$1" 2> /dev/null || echo "No such mark: $1";
  fi
}

# Removes a mark set up above.
function unmark(){
  rm -i "$MARKPATH/$1"
}

# Enumerates all currently set marks.
function marks(){
  if [ ! -d $MARKPATH ]; then mkdir -p $MARKPATH; fi
  ls -l $MARKPATH | awk '{print $9, $10, $11}' | column -t
}

# Completion function for jump/unmark
function _completemarks() {
  local curw=${COMP_WORDS[COMP_CWORD]}
  local wordlist=$(find $MARKPATH -maxdepth 1 -type l,d -exec basename {} \;)
  COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
  return 0
}

# Function to switch kubernetes namespace.
function n(){
  kubectl config set-context $(kubectl config current-context) --namespace=$1
}

# Function to switch kubernetes namespace.
function kc(){
  kubectl config use-context $1
}

# Function to try and bash into a kube pod.
function kbash(){
  kubectl exec $1 -it -- bash
}

# Function to run some useful lein things and open the output in sublime.
function lein-(){
  echo "Compiling..."
  lein compile
  echo "Checking user plugins..."
  lein ancient check-profiles
  echo "Doing things... (editor will open upon completion with outputs)"
  echo "Ancient:"
  lein ancient :no-colours &> /tmp/ancient.txt
  echo "Bikeshed:"
  lein bikeshed -v -m 80 &> /tmp/bikeshed.md
  sed -i -r 's|^#''|  * #''|' /tmp/bikeshed.md
  sed -i 's/Checking/# Checking/' /tmp/bikeshed.md
  sed -i -r 's|(/home/[^:]+:[0-9]+:)|`\1`\n|' /tmp/bikeshed.md
  echo "Kibit:"
  lein kibit --reporter markdown &> /tmp/kibit.md
#  echo "Repetition-hunter:"
#  lein repetition-hunter &> /tmp/hunter.txt
  subl -n /tmp/ancient.txt /tmp/bikeshed.md /tmp/kibit.md  --command toggle_full_screen
  #/tmp/hunter.txt
}

# Function to run some common deploy steps in sequence.
function lein+(){
  echo "Compiling..."
  lein compile
  echo "Uberjarring"
  lein uberjar
  echo "Testing"
  lein test
}
