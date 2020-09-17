#!/bin/zsh
# prerequisite
# - `gdate`

typeset -A INTERVALS

INTERVAL_1=`bc <<< '60 * 30'`
INTERVAL_2=`bc <<< '60 * 60 * 2'`
INTERVAL_3=`bc <<< '60 * 60 * 6'`
INTERVAL_4=`bc <<< '60 * 60 * 24'`
INTERVAL_5=`bc <<< '60 * 60 * 24 * 3'`
INTERVAL_6=`bc <<< '60 * 60 * 24 * 7'`
INTERVAL_7=`bc <<< '60 * 60 * 24 * 30'`
INTERVAL_8=`bc <<< '60 * 60 * 24 * 30 * 3'`
INTERVAL_9=`bc <<< '60 * 60 * 24 * 30 * 6'`

INTERVALS[${INTERVAL_1}]=${INTERVAL_2}
INTERVALS[${INTERVAL_2}]=${INTERVAL_3}
INTERVALS[${INTERVAL_3}]=${INTERVAL_4}
INTERVALS[${INTERVAL_4}]=${INTERVAL_5}
INTERVALS[${INTERVAL_5}]=${INTERVAL_6}
INTERVALS[${INTERVAL_6}]=${INTERVAL_7}
INTERVALS[${INTERVAL_7}]=${INTERVAL_8}
INTERVALS[${INTERVAL_8}]=${INTERVAL_9}
INTERVALS[${INTERVAL_9}]=${INTERVAL_9}

# @param {String} his - $1
# @returns {Boolean} false - no need to update
#          {String} history - updated history
update_history() {
  his=$1

  if [[ ${his} == "" ]]; then
    printf '%s' '<details><summary>History</summary>\n\n- `'${INTERVAL_1}'` | `'"$(gdate --rfc-3339=s)"'`\n\n</details>'
    exit
  fi

  the_last_his=
  printf "${his}" | while read line; do
    if [[ ! $line =~ '^<.+>' ]] && [[ $line != "" ]]; then
      the_last_his="$line"
    fi
  done

  interval=$(printf '%s' "${the_last_his:2}" | cut -d '|' -f 1 | cut -d '`' -f 2)
  last_datetime=$(printf '%s' "${the_last_his:2}" | cut -d '|' -f 2 | cut -d '`' -f 2)

  next_notify_timestamp=$(bc <<< "$(gdate -d "${last_datetime}" +%s) + ${interval}")
  if [[ "${next_notify_timestamp}" > "$(gdate +%s)" ]]; then
    printf "false"
  else
    new_his='- `'${INTERVALS[${interval}]}'` | `'$(gdate --rfc-3339=s)'`'
    printf '%s' "${his}" | sed "s/${the_last_his}/&\\\n\\\n${new_his}/"
  fi
}
