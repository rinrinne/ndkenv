if [[ ! -o interactive ]]; then
    return
fi

compctl -K _ndkenv ndkenv

_ndkenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(ndkenv commands)"
  else
    completions="$(ndkenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
