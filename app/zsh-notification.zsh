#!/bin/zsh
# deps
#   terminal-notifier
#   brew install terminal-notifier

# 0=${(%):-%N}
# source ${0:A:h}/zsh-cache.zsh
[[ -e ~/.ghfrc ]] && source ~/.ghfrc


notify() {
  usage() {
    echo "usage:
      [-t|--title]
      [-m|--message]
      [-u|--url]
      [-h]"
  }

  while [ "$1" != "" ]; do
    case $1 in
      -t | --title ) shift
        title=$1
        ;;
      -m | --message ) shift
        message=$1
        ;;
      -u | --url ) shift
        url=$1
        ;;
      -h | --help )
        usage
        exit
        ;;
      * )
        usage
        exit 1
    esac
    shift
  done

  if type terminal-notifier 1>/dev/null; then
    terminal-notifier -title "${title:-EBFC}" -message "${message}" -open "${url}" -sound ${ZSH_GHF_NOTIFICATION_SOUND:-submarine} -appIcon https://user-images.githubusercontent.com/11631972/93462166-783cc000-f918-11ea-96dc-598c52179eae.png
  else
    echo "Please install terminal-notifier!"
    echo "\$ brew install terminal-notifier"
    exit 1
  fi
}

# notify -t '`k8s` `api`' -m "k8s can refactor yaml by apiVersion" -u "https://github.com/soraliu/dev-infra/issues/49#issuecomment-673845720"
