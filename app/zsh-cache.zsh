#!/bin/zsh

set -e

0=${(%):-%N}
source ${0:A:h}/zsh-github-api.zsh
source ${0:A:h}/zsh-history-operator.zsh
source ${0:A:h}/zsh-notification.zsh
source ${0:A:h}/zsh-utils.zsh
[[ -e ~/.ghfrc ]] && source ~/.ghfrc

# @param {Number} issue number - $1
# @param {Number=} comment index - $2
issue_to_cache() {
  usage() {
    echo "usage:
      [-r|--repo_name]
      [-n|--issue_number]
      [-i|--index_of_comment]
      [-h]"
  }

  while [ "$1" != "" ]; do
    case $1 in
      -r | --repo_name ) shift
        repo_name=$1
        ;;
      -n | --issue_number ) shift
        number=$1
        ;;
      -i | --index_of_comment ) shift
        index_of_comment=$1
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

  comments=[$(get_comments_by_issue_number -r ${repo_name} -n ${number} | jq -r ".[${index_of_comment}] | @base64" | while read comment; do
    comment=$(printf '%s' "${comment}" | base64 --decode | jq '. | {id, body, created_at, html_url}')
    body=$(trim_double_quote "$(printf '%s' "${comment}" | sed -E 's/\\r//g' | jq '.body')")
    comment=$(printf '%s' "${comment}" | jq '.body="'${body}'"')

    tags=[]
    # to ensure that only to match the first line as tags
    no_tags=
    content=
    IFS=''
    echo ${body} | while read -r line; do
      if [[ ${no_tags} == "" && ${line} =~ '^\s*(`[^`]+`\s*)+' ]]; then
        # tags=[$(printf '%s' "${line}" | sed -E 's/`(.+)` /\1 /g' | sed -E 's/`(.+)`$/\1/g' | xargs -n1 printf '"%s"\n' | paste -s -d ',' -)]
        tags=[$(printf '%s' "${line}" | sed -E 's/`/"/g' | xargs -n1 printf '"%s"\n' | paste -s -d ',' -)]
      elif [[ "${line}" =~ '^<details>.*$' ]]; then
        history_of_comment=$(printf "${body}" | awk '/^<details>.*$/,EOF {print $0}')
        break
      else
        content="${content}$(trim_double_quote "$(jq -aRs <<< "${line}")")"
      fi
      no_tags="true"
    done
    custom_comment=$(echo '{}' | jq -r '.number="'${number}'"|.tags='${tags}'|.history="'${history_of_comment}'"|.content="'${content}'"')

    cached_comment=$(printf '%s ' "${comment} ${custom_comment}" | jq -s add)
    printf '%s' "$cached_comment" | tr -d '\n'
    printf '\n'
  done | paste -s -d ',' -)]

  printf '%s' "$comments"
}

sync_all() {
  usage() {
    echo "usage:
      [-r|--repo_name]
      [-h]"
  }

  repo_name=${ZSH_GHF_REPO_NAME_FRAGMENT}
  while [ "$1" != "" ]; do
    case $1 in
      -r | --repo_name ) shift
        repo_name=$1
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
  path_to_cache=${ZSH_GHF_PATH_TO_CACHE_ROOT}/${repo_name}

  mkdir -p ${path_to_cache}

  get_all_opened_issues | jq -r '.[] | @base64' | while read issue; do
    number=$(echo ${issue} | base64 --decode | jq -r '.number')
    title=$(echo ${issue} | base64 --decode | jq -r '.title')

    echo "Caching ${repo_name}: pr-${number} | ${title}"

    issue_to_cache -r ${repo_name} -n ${number} > ${path_to_cache}/${title} &
  done

  echo 'Waiting to end'
  wait
}

sync_by_issue_number() {
  usage() {
    echo "usage:
      [-r|--repo_name]
      [-n|--number]
      [-h]"
  }

  repo_name=${ZSH_GHF_REPO_NAME_FRAGMENT}
  while [ "$1" != "" ]; do
    case $1 in
      -r | --repo_name ) shift
        repo_name=$1
        ;;
      -n | --number ) shift
        number=$1
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
  path_to_cache=${ZSH_GHF_PATH_TO_CACHE_ROOT}/${repo_name}

  mkdir -p ${path_to_cache}

  issue=$(get_issue -r ${repo_name} -n ${number})
  number=$(echo ${issue} | jq -r '.number')
  title=$(echo ${issue} | jq -r '.title')

  echo "Caching ${repo_name}: pr-${number} | ${title}"

  issue_to_cache -r ${repo_name} -n ${number} > ${path_to_cache}/${title} &

  echo 'Waiting to end'
  wait
}

update_cache() {
  usage() {
    echo "usage:
      [-r|--repo_name]
      [-f|--file]
      [-h]"
  }

  repo_name=${ZSH_GHF_REPO_NAME_FRAGMENT}
  while [ "$1" != "" ]; do
    case $1 in
      -r | --repo_name ) shift
        repo_name=$1
        ;;
      -f | --path_to_cache_file ) shift
        file=$1
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
  path_to_cache_file=${ZSH_GHF_PATH_TO_CACHE_ROOT}/${repo_name}/${file}

  cat ${path_to_cache_file} | jq -r '.[] | @base64' | while read -r cached_comment; do
    comment=$(echo ${cached_comment} | base64 --decode)

    new_history=$(update_history "$(printf '%s' "${comment}" | jq '.history' | trim_double_quote)")

    if [[ ${new_history} != "false" ]]; then
      html_url=$(printf '%s' "${comment}" | jq -r '.html_url')
      number=$(printf '%s' "${comment}" | jq -r '.number')
      id=$(printf '%s' "${comment}" | jq -r '.id')

      tags=$(printf '%s' "${comment}" | jq -r '.tags | map("`" + . + "`") | join(" ")')
      if [[ ${tags} != "" ]]; then
        tags="${tags}\n"
      fi
      content=$(printf '%s' "${comment}" | jq '.content' | trim_double_quote)

      # echo '------------'
      # printf '%s' "${content}"
      # echo '------------'

      new_body=$(printf '%s' "${tags}${content}${new_history}\n" | tr -d '\n')

      update_comment -r ${repo_name} -i ${id} -b "${new_body}"

      notify -t "$(echo ${tags})" -m "$(echo ${content})" -u "${html_url}"

      sleep ${ZSH_GHF_DAEMON_NOTIFICATION_INTERVAL-15}
    fi
  done

  # the last item's issue number
  if [[ ${number} != "" ]]; then
    echo "Updating exist cache."
    issue_to_cache -r ${repo_name} -n ${number} > ${path_to_cache_file}
    number=
  fi
}

# form testing
# sync_from_github
# sync_by_issue_number -n 1
# issue_to_cache -r ${ZSH_GHF_REPO_NAME_FRAGMENT} -n 1 -i 0
# update_cache -f 2020-08-18
