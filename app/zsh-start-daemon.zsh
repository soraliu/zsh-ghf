#!/bin/zsh

sub_command=$1

path_to_daemon=$(dirname $0)/zsh-daemon.zsh

if [[ "${sub_command}" == "stop" ]]; then

  if [[ $(bc <<< $(ps -ef | grep zsh-ghf/app/zsh-daemon.zsh | wc -l)) > 1 ]]; then
    ps -ef | grep zsh-ghf/app/zsh-daemon.zsh | awk '{print $2}' | head -n1 | xargs kill
    echo "GHF daemon stopped"
    echo "[$(gdate --rfc-3339=s)] GHF daemon stopped" 1>>/tmp/ghf-daemon.stdout
  else
    echo "GHF daemon not start"
    echo "[$(gdate --rfc-3339=s)] GHF daemon not start" 1>>/tmp/ghf-daemon.stdout
  fi

else
  if [[ $(bc <<< $(ps -ef | grep zsh-ghf/app/zsh-daemon.zsh | wc -l)) > 1 ]]; then
    echo "GHF daemon already start"
    echo "[$(gdate --rfc-3339=s)] GHF daemon already start" 1>>/tmp/ghf-daemon.stdout
    exit
  fi

  zsh ${path_to_daemon} 1>>/tmp/ghf-daemon.stdout 2>>/tmp/ghf-daemon.stderr &
  echo "[$(gdate --rfc-3339=s)] GHF daemon started" 1>>/tmp/ghf-daemon.stdout
fi
