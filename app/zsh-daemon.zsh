#!/bin/zsh

# @global {String} ZSH_GHF_API_URL
# @global {String} ZSH_GHF_REPO_NAME_FRAGMENT
# @global {String} ZSH_GHF_REPO_NAME_LANG_LEARNING
# @param {String} repo

set -e

0=${(%):-%N}
source ${0:A:h}/zsh-cache.zsh
[[ -e ~/.ghfrc ]] && source ~/.ghfrc

precheck() {
  if ! type gdate 1>/dev/null; then
    echo 'please install gdate'
    echo 'run: brew install coreutils'
    exit 1
  fi
}

if [[ ${ZSH_GHF_REPO_NAME_FRAGMENT} == ${ZSH_GHF_REPO_NAME_LANG_LEARNING} ]]; then
  repos=(${ZSH_GHF_REPO_NAME_FRAGMENT})
else
  repos=(${ZSH_GHF_REPO_NAME_FRAGMENT} ${ZSH_GHF_REPO_NAME_LANG_LEARNING})
fi

main() {
  while true; do

    for repo_name in ${repos[@]}; do
      path_to_cache=${ZSH_GHF_PATH_TO_CACHE_ROOT}/${repo_name}
      ls ${path_to_cache} | while read cached_file; do
        echo "[$(gdate --rfc-3339=s)] (${repo_name}) Start updating cache. Filename: ${cached_file}"
        update_cache -r ${repo_name} -f ${cached_file}
      done
    done

    echo "[$(gdate --rfc-3339=s)] (${repo_name}) Waiting next loop."
    sleep ${ZSH_GHF_DAEMON_POLLING_INTERVAL:-30}
  done
}

precheck
main
