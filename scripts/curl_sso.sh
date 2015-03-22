die() {
  echo >&2 "$@"
  exit 1
}
auth_prompt () {
  # don't prompt scripts that don't have terminal output
  { test -t 1 && test -t 0; } || return

  echo "Please enter your SSO login and password."
  printf "login: "
  read LOGIN

  stty -echo
  printf "password: "
  read PASSWORD
  stty echo
  echo
}
run_curl () {
  curl_opts=${CURL_OPTS-'-sSf --no-buffer --connect-timeout 5 --retry 3'}
  curl $sso_cookies_arg $curl_opts $v "$@"
}

sso_auth () {
  test "$LOGIN:$PASSWORD" != ":" || auth_prompt
  test "$LOGIN:$PASSWORD" != ":" || die "Could not get SSO credentials"

  sso_pass=`mktemp -t sso_pass.XXXXXX`
  sso_cookies=`mktemp -t sso_cookies.XXXXXX`
  chmod 600 $sso_pass $sso_cookies

  printf '%s' "$PASSWORD" > $sso_pass

  run_curl -L \
    -d login="$LOGIN" --data-urlencode password@$sso_pass \
    -c $sso_cookies \
    https://${SSO_HOST-'sso.yellowpages.com'}/login?noredirects=1 \
    > /dev/null
  > $sso_pass # not needed after this, kill ASAP, trap will rm it
  sso_cookies_arg="-b $sso_cookies"
}
sso_auth
run_curl -F drop_attachment=readme.txt -H Expect: -T "README" "https://drop.atti.com/drops"
