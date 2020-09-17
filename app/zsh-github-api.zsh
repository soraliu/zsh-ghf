#!/bin/zsh

[[ -e ~/.ghfrc ]] && source ~/.ghfrc

get_all_opened_issues() {
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

  curl -s ${ZSH_GHF_API_URL}/${repo_name}/issues
}

get_issue() {
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

  curl -s ${ZSH_GHF_API_URL}/${repo_name}/issues/${number}
}

get_comments_by_issue_number() {
  usage() {
    echo "usage:
      [-r|--repo_name]
      [-n|--issue_number]
      [-h]"
  }

  repo_name=${ZSH_GHF_REPO_NAME_FRAGMENT}
  while [ "$1" != "" ]; do
    case $1 in
      -r | --repo_name ) shift
        repo_name=$1
        ;;
      -n | --issue_number ) shift
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

  curl -s ${ZSH_GHF_API_URL}/${repo_name}/issues/${number}/comments
}

create_comment() {

}

update_comment() {
  usage() {
    echo "usage:
      [-r|--repo_name]
      [-n|--issue_number]
      [-i|--comment_id]
      [-b|--body]
      [-h]"
  }

  repo_name=${ZSH_GHF_REPO_NAME_FRAGMENT}
  while [ "$1" != "" ]; do
    case $1 in
      -r | --repo_name ) shift
        repo_name=$1
        ;;
      -i | --comment_id ) shift
        comment_id=$1
        ;;
      -b | --body ) shift
        body=$1
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

  data='{"body": "'"${body}"'"}'
  api=${ZSH_GHF_API_URL}/${repo_name}/issues/comments/${comment_id}
  curl -sX PATCH --data "${data}" ${api} 1>/dev/null
}

close_issue_by_id() {

}
