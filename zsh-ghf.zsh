[[ -e ~/.ghfrc ]] && source ~/.ghfrc

0=${(%):-%N}
typeset -g ZSH_GHF_VERSION=$(<"${0:A:h}"/.version)
typeset -g ZSH_GHF_REVISION=$(<"${0:A:h}"/.revision-hash)
typeset -g ZSH_GHF_DEBUG=false

pre-check() {
  if [[ $ZSH_GHF_API_URL == "" ]]; then
    echo 'please configure $ZSH_GHF_API_URL in ~/.ghfrc'
    echo 'TL;DR https://github.com/soraliu/zsh-ghf'
    return 1
  fi

  if [[ $ZSH_GHF_REPO_NAME_FRAGMENT == "" ]]; then
    echo 'please configure $ZSH_GHF_REPO_NAME_FRAGMENT in ~/.ghfrc'
    echo 'TL;DR https://github.com/soraliu/zsh-ghf'
    return 1
  fi

  if ! command -v jq 1>/dev/null 2>&1; then
    echo 'please install jq'
    echo 'TL;DR https://github.com/soraliu/zsh-ghf'
    return 1
  fi

  if ! command -v curl 1>/dev/null 2>&1; then
    echo 'please install curl'
    echo 'TL;DR https://github.com/soraliu/zsh-ghf'
    return 1
  fi
}

ghf() {
  set -e
  pre-check

  usage() {
    echo "usage:
      [-t | --tag]
      [-c | --is_code [if wrap comment with \`\`\`]]
      [-h]"
  }

  if [[ ${ZSH_GHF_REPO_NAME} == "" ]]; then
    ZSH_GHF_REPO_NAME=${ZSH_GHF_REPO_NAME_FRAGMENT}
  fi

  comment=
  tags=
  api=${ZSH_GHF_API_URL}/${ZSH_GHF_REPO_NAME}/issues
  today=$(date +"%Y-%m-%d")

  while [ "$1" != "" ]; do
    case $1 in
      -t | --tag ) shift
        if ! echo $tags | grep "\`$1\`" 1>/dev/null 2>&1; then
          tags="$tags\`$1\` "
        fi
        ;;
      -c | --code )
        is_code=true
        ;;
      -h | --help )
        usage
        return
        ;;
      * )
        if [[ $comment == "" ]]; then
          comment="$1"
        else
          comment="$comment

$1"
        fi
    esac
    shift
  done

  if command -v wrapper 1>/dev/null 2>&1; then
    comment=$(wrapper $comment)
  fi

  # if is_code, wrap comment with ```
  if [[ $is_code == true ]]; then
    comment="\`\`\`
$comment
\`\`\`"
  fi

  if [[ ${ZSH_GHF_DEBUG} == true ]]; then
    echo api: $api
    echo today: $today
  fi


  # get pr number if exist
  id=$(curl -s $api | jq ".[] | select(.title == \"${today}\") | .number")

  if [[ "" == "$id" ]]; then
    # create issue
    id=$(curl -s -X POST --data '{"title": "'$today'"}' $api | jq '.number')
  fi

  if [[ ${ZSH_GHF_DEBUG} == true ]]; then
    echo issue id: $id
  fi

  if [[ $tags == "" ]]; then
    body="${comment}"
  else
    body="${tags}

${comment}"
  fi
  echo $(curl -s -X POST --data '{"body": '"$(jq -aRs . <<< $(echo ${body}))"'}' $api/$id/comments | jq -r '.html_url')
  echo "$body"
}

dict() {
  wrapper() {
    trans -no-ansi $1
  }

  ZSH_GHF_REPO_NAME=${ZSH_GHF_REPO_NAME_LANG_LEARNING}
  ghf -c $@
}

tozh() {
  wrapper() {
    trans -no-ansi en:zh $1
  }

  ZSH_GHF_REPO_NAME=${ZSH_GHF_REPO_NAME_LANG_LEARNING}
  ghf -c $@
}

toen() {
  wrapper() {
    trans -no-ansi zh:en $1
  }

  ZSH_GHF_REPO_NAME=${ZSH_GHF_REPO_NAME_LANG_LEARNING}
  ghf -c $@
}

alias push="ghf"
