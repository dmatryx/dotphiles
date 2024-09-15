################################################################################
## Aliases
################################################################################

# Kubectl
alias k='kubectl'
alias kl='kubectl logs'
alias lns="kubectl get namespace -l 'prometheus in (customer-platform,ldn,data-engineering)'"

################################################################################
## Session specific kubeconfig handling
################################################################################

## Setting up session specific kubeconfig
kcfile=/tmp/kubeconfig-$RANDOM.json
kubectl config view --flatten --merge --output json > $kcfile
export KUBECONFIG=$kcfile
trap "rm -f $kcfile" EXIT

################################################################################
## Functions
################################################################################

# Function to switch kubernetes namespace.
function n(){
  # We're doing this twice.  Once to change the session based entry, then once to change the global - in case new terminal windows are opened
  # The first command we're sending output to dev/null because both will say the same thing (hopefully).
  kubectl config set-context $(kubectl config current-context) --namespace=$1 > /dev/null
  KUBECONFIG_SAVED="${KUBECONFIG}"
  KUBECONFIG=""
  kubectl config set-context $(kubectl config current-context) --namespace=$1
  KUBECONFIG="${KUBECONFIG_SAVED}"
}

# Function to switch kubernetes context (cluster).
function kc(){
  kubectl config use-context $1 > /dev/null
  KUBECONFIG_SAVED="${KUBECONFIG}"
  KUBECONFIG=""
  kubectl config use-context $1
  KUBECONFIG="${KUBECONFIG_SAVED}"
}

# Function to try and bash into a kube pod.
function kbash(){
  kubectl exec $1 -it -- bash
}

# Function to decode and output kube secrets
function kdecode(){
  for row in $(kubectl get secret $1 -o json | jq -c '.data | to_entries[]'); do
    K=$(echo "${row}" | jq -r '.key')
    V=$(echo "${row}" | jq -r '.value' | base64 --decode)
    echo "${K}:${V}"
  done
}

################################################################################
## Completion Script
################################################################################

source <(kubectl completion bash)