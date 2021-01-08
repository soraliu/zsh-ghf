ghf-log() {
  usage() {
    echo "usage:
      [-c | --content]
      [-h]"
  }

  while [ "$1" != "" ]; do
    case $1 in
      -c | --content ) shift
        content=$1
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

  echo "[$(gdate --rfc-3339=s)]: ${content}" 1>>/tmp/ghf-log.stdout
}

