#!/bin/zsh

upload_file_to_aliyun_oss() {
  [[ -e ~/.ghfrc ]] && source ~/.ghfrc

  access_key_id=${ZSH_GHF_ALIYUN_OSS_ACCESS_KEY_ID}
  access_key_secret=${ZSH_GHF_ALIYUN_OSS_ACCESS_KEY_SECRET}
  host=${ZSH_GHF_ALIYUN_OSS_HOST}
  bucket=${ZSH_GHF_ALIYUN_OSS_BUCKET}

  if [[
    ${access_key_id} == ""
    || ${access_key_secret} == ""
    || ${host} == ""
    || ${bucket} == ""
  ]]; then
    echo "Please set oss envs."
    exit 1
  fi

  usage() {
    echo "usage:
      [-s | --src]
      [-d | --dest]
      [-h]"
  }

  while [ "$1" != "" ]; do
    case $1 in
      -s | --src ) shift
        src=$1
        ;;
      -d | --dest ) shift
        if [[ ${ZSH_GHF_ALIYUN_OSS_BUCKET_DIR} == "" ]]; then
          dest="$1"
        else
          dest="${ZSH_GHF_ALIYUN_OSS_BUCKET_DIR}/$1"
        fi
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

  oss_host=$bucket.$host
  resource="/${bucket}/${dest}"
  content_type=`file -Ib ${src} | awk -F ";" '{print $1}'`
  date_value="`TZ=GMT env LANG=en_US.UTF-8 date +'%a, %d %b %Y %H:%M:%S GMT'`"
  string_to_sign="PUT\n\n${content_type}\n${date_value}\n${resource}"
  signature=`echo -en ${string_to_sign} | openssl sha1 -hmac ${access_key_secret} -binary | base64`

  url=http://${oss_host}/${dest}

  curl -qis -X PUT -T "${src}" \
    -H "Host: ${oss_host}" \
    -H "Date: ${date_value}" \
    -H "Content-Type: ${content_type}" \
    -H "Authorization: OSS ${access_key_id}:${signature}" \
    ${url} 1>/dev/null

  echo "https://${oss_host}/${dest}"
}
