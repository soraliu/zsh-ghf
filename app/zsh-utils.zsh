trim_double_quote() {
  input=$@

  if [[ $# == 0 ]]; then
    read -r input
  fi

  if [[ ${#input} > 1 && ${input[1]} == '"' && ${input[${#input}]} == '"' ]]; then
    printf '%s' ${input:1:0-1}
  else
    printf '%s' ${input}
  fi

  input=
}
