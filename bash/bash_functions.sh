function dotsync {
  (
    cd ~
    ./.dotfiles/dotsync/bin/dotsync -L
  )
}

export -f dotsync

## Display and utility functions go here
function colourizePath {
  IFS='/';
  pathParts=($1);
  unset IFS;
  arrayCount=${#pathParts[@]}
  for i in "${!pathParts[@]}"; do
    colourToUse=$[${arrayCount}-${i}];
    case ${colourToUse} in
      1)
        echo -en '\e[36m';
        echo -n ${pathParts[$i]};
        echo -en '\e[0m';
        ;;
      2)
        echo -en '\e[32m';
        echo -n ${pathParts[$i]};
        echo -en '\e[0m';
        echo -en '\e[33m';
        echo -n /
        echo -en '\e[0m';
        ;;
      3)
        echo -en '\e[93m';
        echo -n ${pathParts[$i]};
        echo -en '\e[0m';
        echo -en '\e[33m';
        echo -n /
        echo -en '\e[0m';
        ;;
      4)
        echo -en '\e[91m';
        echo -n ${pathParts[$i]};
        echo -en '\e[0m';
        echo -en '\e[33m';
        echo -n /
        echo -en '\e[0m';
        ;;
      *)
        echo -en '\e[31m';
        echo -n ${pathParts[$i]};
        echo -en '\e[0m';
        echo -en '\e[33m';
        echo -n /
        echo -en '\e[0m';
        ;;
    esac
  done
}

export -f colourizePath

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

export -f gitSafeFF

# This function will either selectively update, or batch update refspecs it can locate.
# Where possible it will fastforward, but it will update in all cases the status of the branch.
function gup {
  currentbranch="$(git rev-parse --abbrev-ref HEAD)"

  for REF in `git remote`
  do
    echo -e "Fetching \e[33m${REF}\e[0m With Prune and Tags"
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
        echo -e "\033[90mIgnoring\033[0m : '$(colourizePath ${REF})' - No upstream configured for this branch."
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

export -f gup
